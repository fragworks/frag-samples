import
  frag/math/fpu_math,
  frag/math/rectangle,
  frag/graphics/two_d/spritebatch,
  frag/graphics/two_d/texture

type
  Direction = enum
    North, South, East, West

  InvaderArmy* = ref object
    invadersAlive*: int
    invaders*: array[55, Invader]
    position*: Vec2
    firstCol*, firstRow*: int
    lastCol*, lastRow*: int
    lastDirection: Direction
    direction: Direction
    boundsTop, boundsRight: float
    nextY: float
    
  
  Invader* = ref object
    texture: Texture
    relPos: Vec2
    boundingBox*: Rectangle
    dead*: bool

proc updateBounds*(invaderArmy: InvaderArmy) =
  var allInvadersInColDead = true
  while allInvadersInColDead:
    for row in invaderArmy.firstRow..<invaderArmy.lastRow:
      if not invaderArmy.invaders[11 * row + invaderArmy.firstCol].dead:
        allInvadersInColDead = false
    if allInvadersInColDead:
      invaderArmy.firstCol += 1
  
  allInvadersInColDead = true

  while allInvadersInColDead:
    for row in invaderArmy.firstRow..<invaderArmy.lastRow:
      if not invaderArmy.invaders[11 * row + (invaderArmy.lastCol - 1)].dead:
        allInvadersInColDead = false
    if allInvadersInColDead:
      invaderArmy.lastCol -= 1

proc init*(invaderArmy: InvaderArmy, invaderTexture: Texture, boundsTop, boundsRight: float) =
  invaderArmy.lastCol = 11
  invaderArmy.lastRow = 5
  invaderArmy.position = [0f32, 0f32]
  invaderArmy.direction = East
  invaderArmy.boundsTop = boundsTop
  invaderArmy.boundsRight = boundsRight
  invaderArmy.invadersAlive = 55
  for x in 0..<11:
    for y in 0..<5:
      if x == 0:
        let relY = invaderArmy.boundsTop - ((y * 30).float32 + 20f32 + invaderTexture.data.h.float32 * 0.25)
        invaderArmy.invaders[11 * y + x] = Invader(
          texture: invaderTexture,
          relPos: [20f32, relY],
          boundingBox: Rectangle(
            x: 20,
            y: relY,
            width: invaderTexture.data.w.float * 0.25,
            height: invaderTexture.data.h.float * 0.25,
          )
        )
      else:
        let relX = (x * 30).float32 + invaderTexture.data.w.float32 * 0.25.float32
        let relY = invaderArmy.boundsTop - ((y * 30).float32 + 20f32 + invaderTexture.data.h.float32 * 0.25)
        invaderArmy.invaders[11 * y + x] = Invader(
          texture: invaderTexture,
          relPos: [relX, relY],
          boundingBox: Rectangle(
            x: relX,
            y: relY,
            width: invaderTexture.data.w.float * 0.25,
            height: invaderTexture.data.h.float * 0.25,
          )
        )

proc updateBoundingBoxes(invaderArmy: InvaderArmy, relX, relY: float) =
  for invader in invaderArmy.invaders:
    if invader.dead:
      continue
    invader.boundingBox.x += relX
    invader.boundingBox.y += relY

proc update*(invaderArmy: InvaderArmy) =
  case invaderArmy.direction
  of East:
    let invaderArmyX = invaderArmy.position[0] + 20
    var invaderArmyBoundsX = invaderArmyX
    for x in 0..<invaderArmy.lastCol:
      invaderArmyBoundsX += 30
  
    if invaderArmyBoundsX < invaderArmy.boundsRight:
      invaderArmy.position[0] += 1
      invaderArmy.updateBoundingBoxes(1, 0)
    else:
      invaderArmy.lastDirection = East
      invaderArmy.direction = South
      invaderArmy.nextY = invaderArmy.position[1] - 30
  of West:
    var invaderArmyBoundsLeft = invaderArmy.position[0] - invaderArmy.invaders[invaderArmy.lastCol * invaderArmy.firstRow + invaderArmy.firstCol].texture.data.w.float * 0.125
    for x in countDown(invaderArmy.firstCol, 0):
      invaderArmyBoundsLeft += 30f32

    if invaderArmyBoundsLeft > 0:
      invaderArmy.position[0] -= 1
      invaderArmy.updateBoundingBoxes(-1, 0)
    else:
      invaderArmy.lastDirection = West
      invaderArmy.direction = South
      invaderArmy.nextY = invaderArmy.position[1] - 30
  of South:
    if invaderArmy.position[1] > invaderArmy.nextY:
      invaderArmy.position[1] -= 1
      invaderArmy.updateBoundingBoxes(0, -1)
    else:
      if invaderArmy.lastDirection == East:
        invaderArmy.direction = West
      else:
        invaderArmy.direction = East
  else:
    discard

proc draw*(invaderArmy: InvaderArmy, batch: SpriteBatch) =
  for invader in invaderArmy.invaders:
    if invader.dead:
      continue
    if not(invader.relPos == [0f32,0f32]):
      batch.draw(invader.texture, invaderArmy.position[0] + invader.relPos[0], invaderArmy.position[1] + invader.relPos[1], invader.texture.data.w.float, invader.texture.data.h.float, false, 0xffffffff'u32, [0.25f32, 0.25f32, 1.0f32])
