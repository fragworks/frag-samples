import
  hashes,
  random,
  sequtils

import
  sdl2 as sdl
  
import
  frag/logger,
  frag/modules/assets,
  frag/modules/input,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/math/rectangle,
  frag/modules/module,
  frag/sound/sound

import
  ../bomb,
  ../constants,
  ../invaders,
  ../laser,
  ../player,
  ../shield

type
  GameScreen* = ref object
    width, height: float
    visible*: bool
    backgroundTexture: Texture
    backgroundMusicAssetId: Hash
    bombs: seq[Bomb]
    bombsToRemove: seq[Bomb]
    laserTextureAssetId: Hash
    bombTextureAssetId: Hash
    laserSFXAssetId: Hash
    invaderTextureAssetId: Hash
    shieldTextureAssetId: Hash
    player: Player
    playerTextureAssetId: Hash
    lasers: seq[Laser]
    lasersToRemove: seq[Laser]
    shieldArrays: array[4, ShieldArray]
    invaderArmy: InvaderArmy

var lastShotFired = 0u32
var lastBombDropped = 0u32

proc resize*(screen: GameScreen, width, height: float) =
  screen.width = width
  screen.height = height
  if screen.player.position[0] > screen.width - 18:
    screen.player.position[0] = float32 screen.width - screen.player.texture.data.w.float32 - 18

proc show*(screen: GameScreen, am: AssetManager): bool =
  result = true
  while not assets.update(am):
    return false
  
  let backgroundMusic = get[Sound](am, screen.backgroundMusicAssetId)
  backgroundMusic.setGain(0.1)
  backgroundMusic.loop(true)
  backgroundMusic.play()

  let playerTexture = get[Texture](am, screen.playerTextureAssetId)
  screen.player.init(playerTexture, (screen.width / 2) - (playerTexture.data.w.float32 * 0.5 / 2), 18)

  let invaderTexture = get[Texture](am, screen.invaderTextureAssetId)
  screen.invaderArmy.init(invaderTexture, screen.height, screen.width)
  
  let shieldTexture = get[Texture](am, screen.shieldTextureAssetId)
  let shieldArrayWidth = shieldTexture.data.w * 6
  var shieldArray1 = ShieldArray()
  shieldArray1.init(shieldTexture, [float32 30, float32 15 + playerTexture.data.h + shieldTexture.data.h])
  var shieldArray2 = ShieldArray()
  shieldArray2.init(shieldTexture, [float32 6 + (shieldArrayWidth * 2), float32 15 + playerTexture.data.h + shieldTexture.data.h])
  var shieldArray3 = ShieldArray()
  shieldArray3.init(shieldTexture, [float32 6 + (shieldArrayWidth * 4), float32 15 + playerTexture.data.h + shieldTexture.data.h])
  var shieldArray4 = ShieldArray()
  shieldArray4.init(shieldTexture, [float32 6 + (shieldArrayWidth * 6), float32 15 + playerTexture.data.h + shieldTexture.data.h])
  screen.shieldArrays = [shieldArray1, shieldArray2, shieldArray3, shieldArray4]
  
  screen.visible = true

proc init*(screen: GameScreen, assets: AssetManager, width, height: float, backgroundTexture: Texture, laserTextureAssetId: Hash) =
  screen.visible = false
  screen.width = width
  screen.height = height
  screen.backgroundTexture = backgroundTexture
  screen.laserTextureAssetId = laserTextureAssetId
  screen.lasers = @[]
  screen.lasersToRemove = @[]
  screen.bombs = @[]
  screen.bombsToRemove = @[]

  logInfo "Loading game assets..."
  screen.backgroundMusicAssetId = assets.load(gameBackgroundMusicFilename, AssetType.Sound)
  screen.playerTextureAssetId = assets.load(playerTextureFilename, AssetType.Texture)
  screen.shieldTextureAssetId = assets.load(shieldTextureFilename, AssetType.Texture)
  screen.invaderTextureAssetId = assets.load(invaderTextureFilename, AssetType.Texture)
  screen.bombTextureAssetId = assets.load(bombImageFilename, AssetType.Texture)
  screen.laserSFXAssetId = assets.load(laserSFXFilename, AssetType.Sound)
  screen.player = Player()

  screen.invaderArmy = InvaderArmy()

proc checkShieldCollision(screen: GameScreen) =
  screen.lasersToRemove.setLen(0)
  screen.bombsToRemove.setLen(0)

  for i in 0..<screen.lasers.len:
    for j in 0..<screen.shieldArrays.len:
      for k in 0..<screen.shieldArrays[j].shields.len:
        if screen.shieldArrays[j].shields[k].isNil:
          continue
        if intersects(screen.shieldArrays[j].shields[k].boundingBox, screen.lasers[i].boundingBox):
          screen.shieldArrays[j].shields[k] = nil
          screen.lasersToRemove.add(screen.lasers[i])
          break

  for i in 0..<screen.bombs.len:
    for j in 0..<screen.shieldArrays.len:
      for k in 0..<screen.shieldArrays[j].shields.len:
        if screen.shieldArrays[j].shields[k].isNil:
          continue
        if intersects(screen.shieldArrays[j].shields[k].boundingBox, screen.bombs[i].boundingBox):
          screen.shieldArrays[j].shields[k] = nil
          screen.bombsToRemove.add(screen.bombs[i])
          break

  
  screen.lasers.keepIf(proc(item: Laser): bool = not screen.lasersToRemove.contains item)
  screen.bombs.keepIf(proc(item: Bomb): bool = not screen.bombsToRemove.contains item)

proc checkInvaderCollision(screen: GameScreen) =
  screen.lasersToRemove.setLen(0)

  for i in 0..<screen.lasers.len:
    for j in 0..<screen.invaderArmy.invaders.len:
      if screen.invaderArmy.invaders[j].dead:
        continue
      if intersects(screen.invaderArmy.invaders[j].boundingBox, screen.lasers[i].boundingBox):
        screen.invaderArmy.invaders[j].dead = true
        dec(screen.invaderArmy.invadersAlive)
        screen.lasersToRemove.add(screen.lasers[i])
        if screen.invaderArmy.invadersAlive == 0:
          echo "You WIN!"
        else:
          screen.invaderArmy.updateBounds()
        break

  
  
  screen.lasers.keepIf(proc(item: Laser): bool = not screen.lasersToRemove.contains item)

proc checkPlayerCollision(screen: GameScreen) =
  screen.bombsToRemove.setLen(0)

  for i in 0..<screen.bombs.len:
    if screen.player.lives == 0:
      continue
    if intersects(screen.player.boundingBox, screen.bombs[i].boundingBox):
      screen.player.damage()
      screen.bombsToRemove.add(screen.bombs[i])
      if screen.player.lives == 0:
        echo "You LOSE!"

  
  
  screen.bombs.keepIf(proc(item: Bomb): bool = not screen.bombsToRemove.contains item)

proc update*(screen: GameScreen, assets: AssetManager, input: Input, deltaTime: float) =
  if input.down("d", true):
    screen.player.moveRight(deltaTime, screen.width)
  elif input.down("a", true):
    screen.player.moveLeft(deltaTime)
  
  if input.pressed("space") and sdl.getTicks() - lastShotFired > 500u:
    var laserTexture = get[Texture](assets, screen.laserTextureAssetId)
    var playerTexture = get[Texture](assets, screen.playerTextureAssetId)
    lastShotFired = sdl.getTicks()
    let x = float32 screen.player.position[0] + playerTexture.data.w / 4 + laserTexture.data.h / 2
    let y = screen.player.position[1] + screen.player.texture.data.h.float32 / 2
    screen.lasers.add(Laser(
      position: [x, y],
      texture: laserTexture,
      boundingBox: Rectangle(
        x: x - laserTexture.data.h / 2,
        y: y,
        width: laserTexture.data.h.float,
        height: laserTexture.data.w.float
      )
    ))
    let laserSFX = get[Sound](assets, screen.laserSFXAssetId)
    laserSFX.play()

  
  screen.lasersToRemove.setLen(0)
  for laser in screen.lasers:
    laser.update(deltaTime)
    if laser.position[1] > screen.height:
      screen.lasersToRemove.add(laser)
  
  screen.lasers.keepIf(proc(item: Laser): bool = not screen.lasersToRemove.contains item)

  var bombTexture = get[Texture](assets, screen.bombTextureAssetId)
  var r: float
  let now = getTicks()
  for invader in screen.invaderArmy.invaders:
    r = random(1.0)
    if r * 100 <= 0.05 and not invader.dead and now - lastBombDropped >= 2500u:
      lastBombDropped = getTicks()
      let bombPos = [invader.boundingBox.x.float32 + (invader.boundingBox.width / 2).float32, invader.boundingBox.y.float32 + invader.boundingBox.height.float32]
      screen.bombs.add(Bomb(
        position: bombPos,
        texture: bombTexture,
        boundingBox: Rectangle(
          x: bombPos[0],
          y: bombPos[1],
          width: bombTexture.data.h.float * 0.5,
          height: bombTexture.data.w.float * 0.5
        )
      ))

  for bomb in screen.bombs:
    bomb.update(deltaTime)
    if bomb.position[1] < 0:
      screen.bombsToRemove.add(bomb)

  screen.bombs.keepIf(proc(item: Bomb): bool = not screen.bombsToRemove.contains item)

  screen.invaderArmy.update()

  screen.checkShieldCollision()
  screen.checkInvaderCollision()
  screen.checkPlayerCollision()

proc render*(screen: GameScreen, batch: SpriteBatch, deltaTime: float) =
  #app.batch.begin()
  #app.batch.draw(tex, 0, 0, WIDTH, HEIGHT, true)
  #app.batch.draw(app.player.texture, app.player.position[0], app.player.position[1], float app.player.texture.data.w, float app.player.texture.data.h)
  #app.batch.`end`()

  batch.begin()
  batch.draw(screen.backgroundTexture, 0, 0, screen.width, screen.height, true)
  screen.player.draw(batch, deltaTime)

  for laser in screen.lasers:
    laser.draw(batch)

  for bomb in screen.bombs:
    bomb.draw(batch)

  for shieldArray in screen.shieldArrays:
    shieldArray.draw(batch)

  screen.invaderArmy.draw(batch)

  batch.`end`()