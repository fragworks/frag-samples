import
  frag/graphics/camera,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture

type
  GameScreen* = ref object
    background: Texture
    camera: Camera

proc init*(screen: GameScreen, backgroundTexture: Texture) =
  screen.background = backgroundTexture
  screen.camera = Camera()
  screen.camera.init()
  screen.camera.ortho(1.0, 200, 200)

proc render*(screen: GameScreen, batch: SpriteBatch) =
  screen.camera.update()
  batch.setProjectionMatrix(screen.camera.combined)

  batch.begin()
  batch.draw(screen.background, 0, 0, 960, 540, true)
  batch.`end`()