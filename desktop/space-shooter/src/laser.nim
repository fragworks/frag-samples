import
  math

import
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/math/fpu_math

const SPEED = 350.0

type
  Laser* = ref object
    position*: Vec2
    texture*: Texture

proc init*(laser: Laser, texture: Texture, x, y: float32) =
  laser.texture = texture
  laser.position = [x, y]

proc draw*(laser: Laser, batch: SpriteBatch) =
  batch.draw(laser.texture, laser.position[0], laser.position[1], laser.texture.data.w.float, laser.texture.data.h.float, false, 0xFFFFFFFFu32, [1.0'f32, 1.0'f32, 1.0'f32], 90)

proc update*(laser: Laser, deltaTime: float) =
  laser.position[1] += SPEED * deltaTime