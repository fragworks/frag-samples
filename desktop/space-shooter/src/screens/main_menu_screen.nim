import
  hashes

import
  frag/logger,
  frag/modules/assets,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/modules/gui,
  frag/modules/module,
  frag/sound/sound

type
  MainMenuScreen* = ref object
    width, height: float
    visible*: bool
    backgroundMusicId: Hash
    logoTextureId: Hash
    backgroundScrollXOffset, backgroundScrollYOffset: float

const backgroundMusicFilename = "main_menu.ogg"
const logoTextureFilename = "logo.png"

proc resize*(screen: MainMenuScreen, width, height: float) =
  screen.width = width
  screen.height = height

proc init*(screen: MainMenuScreen, assets: AssetManager, width, height: float) =
  screen.visible = false
  screen.width = width
  screen.height = height
  screen.backgroundScrollXOffset = 0
  screen.backgroundScrollYOffset = 0

  logInfo "Loading main menu assets..."
  screen.backgroundMusicId = assets.load(backgroundMusicFilename, AssetType.Sound)
  screen.logoTextureId = assets.load(logoTextureFilename, AssetType.Texture)
  logInfo "Finished main menu assets..."

proc show*(screen: MainMenuScreen, assetManager: AssetManager) =
  let backgroundMusic = assets.get[Sound](assetManager, screen.backgroundMusicId)
  backgroundMusic.loop(true)
  backgroundMusic.play()
  screen.visible = true

proc render*(screen: MainMenuScreen, gui: GUI, batch: SpriteBatch, assetManager: AssetManager, backgroundTextureId: Hash, deltaTime: float) =
  
  let backgroundTexture = assets.get[Texture](assetManager, backgroundTextureId)
  let logoTexture = assets.get[Texture](assetManager, screen.logoTextureId)

  screen.backgroundScrollXOffset -= 0.1
  if screen.backgroundScrollXOffset < float(-backgroundTexture.data.w):
    screen.backgroundScrollXOffset = 0
  
  screen.backgroundScrollYOffset -= 0.1
  if screen.backgroundScrollYOffset < float(-backgroundTexture.data.h):
    screen.backgroundScrollYOffset = 0

  batch.begin()
  batch.draw(backgroundTexture, float screen.backgroundScrollXOffset, float screen.backgroundScrollYOffset, screen.width * 2, screen.height * 2, true)
  batch.draw(backgroundTexture, float screen.backgroundScrollXOffset + float backgroundTexture.data.w, float screen.backgroundScrollYOffset + float backgroundTexture.data.h, screen.width * 2, screen.height * 2, true)
  
  let logoWidth = float logoTexture.data.w
  let logoHeight = float logoTexture.data.h

  batch.draw(logoTexture, (screen.width / 2.0) - (logoWidth / 2), screen.height - (screen.height / 3.0) - (logoHeight / 2), logoWidth, logoHeight)
  batch.`end`()

  if gui.openWindow("", 0, 0, screen.width, screen.height, WINDOW_NO_SCROLLBAR.ord):
    
    gui.closeWindow()