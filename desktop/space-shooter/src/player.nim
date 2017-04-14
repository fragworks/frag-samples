import
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/math/fpu_math

const SPEED = 350.0

type
  Player* = ref object
    position*: Vec2
    texture*: Texture

proc init*(player: Player, texture: Texture, x, y: float32) =
  player.texture = texture
  player.position = [x, y]

proc draw*(player: Player, batch: SpriteBatch) =
  batch.draw(player.texture, player.position[0], player.position[1], player.texture.data.w.float, player.texture.data.h.float)

proc moveRight*(player:Player, deltaTime: float) =
  player.position[0] += SPEED * deltaTime

proc moveLeft*(player:Player, deltaTime: float) =
  player.position[0] -= SPEED * deltaTime
