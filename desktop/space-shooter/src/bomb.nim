import
  math

import
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/math/fpu_math,
  frag/math/rectangle

const SPEED = 350.0

type
  Bomb* = ref object
    position*: Vec2
    texture*: Texture
    boundingBox*: Rectangle

proc draw*(bomb: Bomb, batch: SpriteBatch) =
  batch.draw(bomb.texture, bomb.position[0], bomb.position[1], bomb.texture.width.float, bomb.texture.height.float, false, 0xFFFFFFFFu32, [0.5'f32, 0.5'f32, 0.5'f32], 180)

proc update*(bomb: Bomb, deltaTime: float) =
  let translateY = SPEED * deltaTime
  bomb.position[1] -= translateY
  bomb.boundingBox.translate(0, -translateY)