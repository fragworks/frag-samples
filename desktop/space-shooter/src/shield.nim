import
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/math/fpu_math,
  frag/math/rectangle

type
  Shield* = ref object
    health*: int
    relativePosition*: Vec2
    texture*: Texture
    boundingBox*: Rectangle

  ShieldArray* =  ref object
    shields*: array[14, Shield]
    position*: Vec2

proc init*(shieldArray: ShieldArray, shieldTexture: Texture, position: Vec2) =
  shieldArray.position = position
  shieldArray.shields = [
    Shield(
      health: 100,
      relativePosition: [float32 0, 0],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0],
        y: shieldArray.position[1],
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w, 0],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float,
        y: shieldArray.position[1],
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 4, 0],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 4,
        y: shieldArray.position[1],
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 5, 0],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 5,
        y: shieldArray.position[1],
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [0f32, float32 shieldTexture.data.h],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0],
        y: shieldArray.position[1] + shieldTexture.data.h.float,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w, float32 shieldTexture.data.h],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float,
        y: shieldArray.position[1] + shieldTexture.data.h.float,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 2, float32 shieldTexture.data.h],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 2,
        y: shieldArray.position[1] + shieldTexture.data.h.float,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 3, float32 shieldTexture.data.h],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 3,
        y: shieldArray.position[1] + shieldTexture.data.h.float,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 4, float32 shieldTexture.data.h],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 4,
        y: shieldArray.position[1] + shieldTexture.data.h.float,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 5, float32 shieldTexture.data.h],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 5,
        y: shieldArray.position[1] + shieldTexture.data.h.float,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),   
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w, float32 shieldTexture.data.h * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float,
        y: shieldArray.position[1] + shieldTexture.data.h.float * 2,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 2, float32 shieldTexture.data.h * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 2,
        y: shieldArray.position[1] + shieldTexture.data.h.float * 2,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 3, float32 shieldTexture.data.h * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 3,
        y: shieldArray.position[1] + shieldTexture.data.h.float * 2,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.data.w * 4, float32 shieldTexture.data.h * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.data.w.float * 4,
        y: shieldArray.position[1] + shieldTexture.data.h.float * 2,
        width: shieldTexture.data.w.float,
        height: shieldTexture.data.h.float
      )
    )
  ]

proc draw*(shieldArray: ShieldArray, batch: SpriteBatch) =
  for shield in shieldArray.shields:
    if not shield.isNil:
      batch.draw(shield.texture, shieldArray.position[0] + shield.relativePosition[0], shieldArray.position[1] + shield.relativePosition[1], shield.texture.data.w.float, shield.texture.data.h.float)