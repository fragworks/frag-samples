import bgfxdotnim

import
  frag,
  frag/config,
  frag/graphics/window,
  frag/logger,
  frag/modules/assets,
  frag/modules/graphics,
  frag/graphics/two_d/spritebatch

import
  screens/game_screen

type
  App = ref object
    batch: SpriteBatch
    gameScreen: GameScreen

proc initializeApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."
  app.gameScreen = GameScreen()
  app.gameScreen.init(assets.get[Texture](ctx.assets, ctx.assets.load("background.png", AssetType.Texture, false)))
  
  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)
  logDebug "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x00000000, 1.0, 0)

  app.gameScreen.render(app.batch)

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."
  logDebug "App shut down."

startFrag[App](Config(
  rootWindowTitle: "FRAG",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "frag.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))
