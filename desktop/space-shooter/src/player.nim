import
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/math/fpu_math,
  frag/math/rectangle

const SPEED = 350.0
const HURT_FRAMES = 4
const HURT_DURATION = 1.0

type
  Player* = ref object
    position*: Vec2
    texture*: Texture
    lives*: int
    boundingBox*: Rectangle
    hurt: bool
    hurtFrameCounter: int
    hurtTimer: float

proc init*(player: Player, texture: Texture, x, y: float32) =
  player.texture = texture
  player.position = [x, y]
  player.boundingBox = Rectangle(
    x: x,
    y: y,
    width: player.texture.width.float,
    height: player.texture.height.float
  )
  player.lives = 3

proc draw*(player: Player, batch: SpriteBatch, deltaTime: float) =
  if player.hurt:
    player.hurtTimer += deltaTime
    inc(player.hurtFrameCounter)
    if player.hurtTimer < HURT_DURATION:
      if player.hurtFrameCounter mod HURT_FRAMES == 0:
        return
    else:
      player.hurtTimer = 0
      player.hurt = false

  batch.draw(player.texture, player.position[0], player.position[1], player.texture.width.float, player.texture.height.float, false, 0xffffffff'u32, [0.5f32, 0.5f32, 1.0f32])

  batch.draw(player.texture, player.boundingBox.x, player.boundingBox.y, player.boundingBox.width.float, player.boundingBox.height.float, false, 0xffffffff'u32, [0.5f32, 0.5f32, 1.0f32])

proc moveRight*(player:Player, deltaTime: float, rightBound: float) =
  let dX = SPEED * deltaTime
  if player.position[0] + (player.texture.width / 2) + dX <= rightBound:
    player.position[0] += dx
    player.boundingBox.x += dx

proc moveLeft*(player:Player, deltaTime: float) =
  let dX = SPEED * deltaTime
  if player.position[0] - dx > 0:
    player.position[0] -= dx
    player.boundingBox.x -= dx

proc damage*(player: Player) =
  dec(player.lives)
  player.hurt = true