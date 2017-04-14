import
  hashes,
  sequtils

import
  sdl2 as sdl
  
import
  frag/logger,
  frag/modules/assets,
  frag/modules/input,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/modules/module,
  frag/sound/sound

import
  ../constants,
  ../laser,
  ../player

type
  GameScreen* = ref object
    width, height: float
    visible*: bool
    backgroundTexture: Texture
    backgroundMusicAssetId: Hash
    laserTextureAssetId: Hash
    player: Player
    playerTextureAssetId: Hash
    lasers: seq[Laser]
    lasersToRemove: seq[Laser]

var lastShotFired = 0u32

proc resize*(screen: GameScreen, width, height: float) =
  screen.width = width
  screen.height = height

proc show*(screen: GameScreen, am: AssetManager): bool =
  result = true
  while not assets.update(am):
    return false
  
  let backgroundMusic = get[Sound](am, screen.backgroundMusicAssetId)
  backgroundMusic.loop(true)
  backgroundMusic.play()

  let playerTexture = get[Texture](am, screen.playerTextureAssetId)
  screen.player.init(playerTexture, (screen.width / 2) - (playerTexture.data.w / 2), 20)
  screen.visible = true

proc init*(screen: GameScreen, assets: AssetManager, width, height: float, backgroundTexture: Texture, laserTextureAssetId: Hash) =
  screen.visible = false
  screen.width = width
  screen.height = height
  screen.backgroundTexture = backgroundTexture
  screen.laserTextureAssetId = laserTextureAssetId
  screen.lasers = @[]
  screen.lasersToRemove = @[]

  logInfo "Loading game assets..."
  screen.backgroundMusicAssetId = assets.load(gameBackgroundMusicFilename, AssetType.Sound)
  screen.playerTextureAssetId = assets.load(playerTextureFilename, AssetType.Texture)

  screen.player = Player()

proc update*(screen: GameScreen, assets: AssetManager, input: Input, deltaTime: float) =
  if input.down("d", true):
    if (screen.player.position[0] + screen.player.texture.data.w.float) <= screen.width - 20:
      screen.player.moveRight(deltaTime)
  elif input.down("a", true):
    if (screen.player.position[0] + screen.player.texture.data.w.float) >= (screen.player.texture.data.w + 20).float:
      screen.player.moveLeft(deltaTime)
  
  if input.pressed("space") and sdl.getTicks() - lastShotFired > 1000u32:
    var laserTexture = get[Texture](assets, screen.laserTextureAssetId)
    var playerTexture = get[Texture](assets, screen.playerTextureAssetId)
    lastShotFired = sdl.getTicks()
    screen.lasers.add(Laser(
      position: [float32 screen.player.position[0] + playerTexture.data.w / 2 + laserTexture.data.h / 2, screen.player.position[1] + screen.player.texture.data.h.float32],
      texture: laserTexture
    ))
  
  screen.lasersToRemove.setLen(0)
  for laser in screen.lasers:
    laser.update(deltaTime)
    if laser.position[1] > screen.height:
      screen.lasersToRemove.add(laser)
  
  screen.lasers.keepIf(proc(item: Laser): bool = not screen.lasersToRemove.contains item)

proc render*(screen: GameScreen, batch: SpriteBatch) =
  #app.batch.begin()
  #app.batch.draw(tex, 0, 0, WIDTH, HEIGHT, true)
  #app.batch.draw(app.player.texture, app.player.position[0], app.player.position[1], float app.player.texture.data.w, float app.player.texture.data.h)
  #app.batch.`end`()

  batch.begin()
  batch.draw(screen.backgroundTexture, 0, 0, screen.width, screen.height, true)
  screen.player.draw(batch)
  for laser in screen.lasers:
    laser.draw(batch)
  batch.`end`()