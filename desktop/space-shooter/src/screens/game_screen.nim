import
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture

type
  GameScreen* = ref object
    background: Texture

proc init*(screen: GameScreen, backgroundTexture: Texture) =
  screen.background = backgroundTexture

proc render*(screen: GameScreen, batch: SpriteBatch) =

  batch.begin()
  batch.draw(screen.background, 0, 0, 960, 540, true)
  batch.`end`()