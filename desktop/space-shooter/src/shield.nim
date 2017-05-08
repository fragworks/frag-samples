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
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width, 0],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float,
        y: shieldArray.position[1],
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 4, 0],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 4,
        y: shieldArray.position[1],
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 5, 0],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 5,
        y: shieldArray.position[1],
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [0f32, float32 shieldTexture.height],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0],
        y: shieldArray.position[1] + shieldTexture.height.float,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width, float32 shieldTexture.height],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float,
        y: shieldArray.position[1] + shieldTexture.height.float,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 2, float32 shieldTexture.height],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 2,
        y: shieldArray.position[1] + shieldTexture.height.float,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 3, float32 shieldTexture.height],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 3,
        y: shieldArray.position[1] + shieldTexture.height.float,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 4, float32 shieldTexture.height],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 4,
        y: shieldArray.position[1] + shieldTexture.height.float,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 5, float32 shieldTexture.height],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 5,
        y: shieldArray.position[1] + shieldTexture.height.float,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),   
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width, float32 shieldTexture.height * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float,
        y: shieldArray.position[1] + shieldTexture.height.float * 2,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 2, float32 shieldTexture.height * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 2,
        y: shieldArray.position[1] + shieldTexture.height.float * 2,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 3, float32 shieldTexture.height * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 3,
        y: shieldArray.position[1] + shieldTexture.height.float * 2,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    ),
    Shield(
      health: 100,
      relativePosition: [float32 shieldTexture.width * 4, float32 shieldTexture.height * 2],
      texture: shieldTexture,
      boundingBox: Rectangle(
        x: shieldArray.position[0] + shieldTexture.width.float * 4,
        y: shieldArray.position[1] + shieldTexture.height.float * 2,
        width: shieldTexture.width.float,
        height: shieldTexture.height.float
      )
    )
  ]

proc draw*(shieldArray: ShieldArray, batch: SpriteBatch) =
  for shield in shieldArray.shields:
    if not shield.isNil:
      batch.draw(shield.texture, shieldArray.position[0] + shield.relativePosition[0], shieldArray.position[1] + shield.relativePosition[1], shield.texture.width.float, shield.texture.height.float)