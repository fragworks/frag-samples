import
  math

import
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/math/fpu_math,
  frag/math/rectangle

const SPEED = 350.0

type
  Laser* = ref object
    position*: Vec2
    texture*: Texture
    boundingBox*: Rectangle

proc draw*(laser: Laser, batch: SpriteBatch) =
  batch.draw(laser.texture, laser.position[0], laser.position[1], laser.texture.width.float, laser.texture.height.float, false, 0xFFFFFFFFu32, [1.0'f32, 1.0'f32, 1.0'f32], 90)

proc update*(laser: Laser, deltaTime: float) =
  let translateY = SPEED * deltaTime
  laser.position[1] += translateY
  laser.boundingBox.translate(0, translateY)