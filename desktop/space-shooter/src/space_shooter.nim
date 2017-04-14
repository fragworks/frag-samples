import
  events,
  hashes,
  tables

import 
  bgfxdotnim,
  sdl2 as sdl

import
  frag,
  frag/graphics/camera,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/graphics/window,
  frag/math/fpu_math,
  frag/gui/themes/gui_themes,
  frag/modules/assets,
  frag/modules/gui

import
  constants,
  player,
  screens/loading_screen,
  screens/main_menu_screen,
  screens/game_screen,
  state

type
  App = ref object
    batch: SpriteBatch
    gameCamera, guiCamera: Camera
    assetIds: Table[string, Hash]
    player: Player
    loadingScreen: LoadingScreen
    mainMenuScreen: MainMenuScreen
    gameScreen: GameScreen
    state: AppState

const WIDTH = 960
const HEIGHT = 540

var displayDataDirty = false
var displayData: Point
var lastLaserPos = -1.0

proc resizeApp*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  
  let app = cast[App](event.userData)
  
  let w = sdlEventData.window.data1.float
  let h = sdlEventData.window.data2.float

  app.mainMenuScreen.resize(w, h)
  app.gameScreen.resize(w, h)
  app.guiCamera.ortho(1.0, w, h, true)
  app.gameCamera.ortho(1.0, w, h)

  displayDataDirty = true

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  app.assetIds = initTable[string, Hash]()

  # Load loading screen and main menu backgrounds
  app.assetIds.add(laserImageFilename, ctx.assets.load(laserImageFilename, AssetType.Texture))
  app.assetIds.add(loadingImageFilename, ctx.assets.load(loadingImageFilename, AssetType.Texture))
  app.assetIds.add(spaceBackgroundFilename, ctx.assets.load(spaceBackgroundFilename, AssetType.Texture))
  while not assets.update(ctx.assets):
    discard
    
  let backgroundTexture = assets.get[Texture](ctx.assets, app.assetIds[spaceBackgroundFilename])

  app.loadingScreen = LoadingScreen()

  app.mainMenuScreen = MainMenuScreen()
  app.mainMenuScreen.init(ctx.assets, WIDTH, HEIGHT, backgroundTexture)

  app.gameScreen = GameScreen()
  app.gameScreen.init(ctx.assets, WIDTH, HEIGHT, backgroundTexture, app.assetIds[laserImageFilename])

  # Set up event handlers
  ctx.events.on(SDLEventType.WindowResize, resizeApp)

  #let playerTexture = assets.get[Texture](ctx.assets, app.assetIds["player.png"])
  #let texHalfW = playerTexture.data.w / 2
  #let texHalfH = playerTexture.data.h / 2
  #app.player = Player()
  #app.player.init(
  #  playerTexture,
  #  float32 HALF_WIDTH - texHalfW,
  #  float32 THIRD_HEIGHT - texHalfH
  #)

  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)

  app.gameCamera = Camera()
  app.guiCamera = Camera()

  app.gameCamera.init(0)
  app.guiCamera.init(1)

  app.gameCamera.ortho(1.0, WIDTH, HEIGHT)
  app.guiCamera.ortho(1.0, WIDTH, HEIGHT, true)

  gui.setTheme(ctx.gui, GUITheme.White)

  app.state = AppState.MainMenu

  displayDataDirty = true

  logDebug "App initialized."

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."

  logDebug "Unloading assets..."
  for _, assetId in app.assetIds:
    ctx.assets.unload(assetId)
  logDebug "Assets unloaded."

  app.batch.dispose()

  logDebug "App shut down..."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  app.gameCamera.update()
  app.guiCamera.update()

  app.batch.setProjectionMatrix(app.gameCamera.combined)
  gui.setProjectionMatrix(ctx.gui, app.guiCamera.combined)

  app.gameScreen.update(ctx.assets, ctx.input, deltaTime)

  

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  if displayDataDirty:
    displayData = ctx.graphics.getSize()
    displayDataDirty = false

  case app.state
  of AppState.MainMenu:
    if not app.mainMenuScreen.visible:
      app.mainMenuScreen.show(ctx.assets)
    app.state = app.mainMenuScreen.render(ctx.gui, app.batch, ctx.assets, deltaTime)
  of AppState.Game:
    if not app.gameScreen.visible:
      if not app.gameScreen.show(ctx.assets):
        let w = displayData.x.float32
        let h = displayData.y.float32
        let backgroundTexture = assets.get[Texture](ctx.assets, app.assetIds[spaceBackgroundFilename])
        let loadingTexture = assets.get[Texture](ctx.assets, app.assetIds[loadingImageFilename])
        let laserTexture = assets.get[Texture](ctx.assets, app.assetIds[laserImageFilename])

        let loadingImageLeft = (w / 2.0) - 150
        let loadingImageTop = h - (h / 2.0) - (150 / 2)
        
        if lastLaserPos == -1:
          lastLaserPos = loadingImageLeft + 100

        let laserDest = lastLaserPos + 100 - laserTexture.data.w.float
        lastLaserPos = flerp(lastLaserPos, laserDest, deltaTime)

        if lastLaserPos >= loadingImageLeft + loadingTexture.data.w.float32:
          lastLaserPos = loadingImageLeft + 100

        app.batch.begin()
        app.batch.draw(backgroundTexture, 0, 0, w, h, true)
        app.batch.draw(loadingTexture, loadingImageLeft, loadingImageTop, loadingTexture.data.w.float, loadingTexture.data.h.float)
        app.batch.draw(laserTexture, lastLaserPos, loadingImageTop + 75 - (laserTexture.data.h / 2), laserTexture.data.w.float, laserTexture.data.h.float)
        app.batch.`end`()

    else:
      app.gameScreen.render(app.batch)
  else:
    discard

startFrag(App(), Config(
  rootWindowTitle: "FRAG - Space Shooter",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: WIDTH, rootWindowHeight: HEIGHT,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))