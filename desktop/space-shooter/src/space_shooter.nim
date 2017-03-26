import
  events,
  hashes,
  tables

import 
  bgfxdotnim,
  sdl2 as sdl

import
  frag,
  frag/events/app_event_handler,
  frag/graphics/camera,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture,
  frag/graphics/window,
  frag/math/fpu_math,
  frag/gui/themes/gui_themes,
  frag/modules/assets,
  frag/modules/gui

import
  screens/main_menu_screen

type
  AppState {.pure.} = enum
    MainMenu, Game

type
  App = ref object
    batch: SpriteBatch
    gameCamera, guiCamera: Camera
    assetIds: Table[string, Hash]
    player: Player
    mainMenuScreen: MainMenuScreen
    state: AppState
    eventHandler: AppEventHandler

  Player = ref object
    position: Vec2
    texture: Texture

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const THIRD_HEIGHT = HEIGHT / 3
const PLAYER_SPEED = 350.0

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  
  let app = cast[App](event.userData)
  
  let w = sdlEventData.window.data1.float
  let h = sdlEventData.window.data2.float

  app.mainMenuScreen.resize(w, h)
  app.guiCamera.ortho(1.0, w, h, true)
  app.gameCamera.ortho(1.0, w, h)

proc initializeApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  app.eventHandler = AppEventHandler()
  app.eventHandler.init(resize)

  app.mainMenuScreen = MainMenuScreen()
  app.mainMenuScreen.init(ctx.assets, WIDTH, HEIGHT)

  app.assetIds = initTable[string, Hash]()

  let filename = "background.png"
  let filename2 = "player.png"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Texture))
  app.assetIds.add(filename2, ctx.assets.load(filename2, AssetType.Texture))
  logDebug "Assets loaded."

  app.player = Player()
  app.player.texture = assets.get[Texture](ctx.assets, app.assetIds["player.png"])

  let texHalfW = app.player.texture.data.w / 2
  let texHalfH = app.player.texture.data.h / 2

  app.player.position = [float32 HALF_WIDTH - texHalfW, THIRD_HEIGHT - texHalfH]

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

  if ctx.input.down("w", true): app.player.position[1] += PLAYER_SPEED * deltaTime
  if ctx.input.down("s", true): app.player.position[1] -= PLAYER_SPEED * deltaTime
  if ctx.input.down("d", true): app.player.position[0] += PLAYER_SPEED * deltaTime
  if ctx.input.down("a", true): app.player.position[0] -= PLAYER_SPEED * deltaTime

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  case app.state
  of AppState.MainMenu:
    if not app.mainMenuScreen.visible:
      app.mainMenuScreen.show(ctx.assets)
    app.mainMenuScreen.render(ctx.gui, app.batch, ctx.assets, app.assetIds["background.png"], deltaTime)
  of AppState.Game:
    let tex = assets.get[Texture](ctx.assets, app.assetIds["background.png"])

    app.batch.begin()
    app.batch.draw(tex, 0, 0, WIDTH, HEIGHT, true)
    app.batch.draw(app.player.texture, app.player.position[0], app.player.position[1], float app.player.texture.data.w, float app.player.texture.data.h)
    app.batch.`end`()

  else:
    discard

startFrag[App](Config(
  rootWindowTitle: "FRAG - Space Shooter",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: WIDTH, rootWindowHeight: HEIGHT,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))
