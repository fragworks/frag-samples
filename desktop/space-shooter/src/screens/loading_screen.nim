import
  frag/graphics/two_d/texture

type
  LoadingScreen* = ref object
    width, height: float
    visible*: bool
    texture: Texture

proc resize*(screen: LoadingScreen, width, height: float) =
  screen.width = width
  screen.height = height