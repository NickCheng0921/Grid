extends Node2D

enum Phases{
	MVMT, MVMT_RSLTN,
	CMBT, CMBT_RSLTN
}

const degreesOfFreedom = 1
export (int) var grid_width = 16
export (int) var grid_height = 16
export var offset = 55
const dirUnitVecs = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]

var Units
var playerFogView = 1
var currTile = null
var Map
var terrainArr
var Tile = load("res://Scenes/Tile.tscn")
var pColors = [Color(0, .5, 0), Color(0, 0, .5)]

var phase = Phases.MVMT
var pcamera
var basicTimerScript
var animationTimer
var currMoveInTurn = 0
var maxMoveInTurn = 0
var currPiece
var currPieceLoc 
var walking = false
var attacking = false
var movement = 0
var head = Vector2(0, 0)
var currFogVal = true

var nodeArr = []
var unitArr = []

var unitLocations = [] #[Vector2(2, 2), Vector2(2, 4), Vector2(4, 4), Vector2(5, 5)]
var unitOwners    = [] #[1, 1, 2, 2] #2 players
var unitType      = [] #[2, 1, 1, 2]
var unitHealth    = []
var unitDirections = [] # 0, 1, 2, 3 -> N, E, S, W
var unitMovements =  {} #0th element in array is unit 1 here
var unitAttacks   =  {} #same layout as movements, key: id, val: Vec2 pos

# Called when the node enters the scene tree for the first time.
func _ready():
	Units = load("res://Scripts/Units.gd")
	basicTimerScript = load("res://Scripts/BasicTimer.gd")
	Map = load("res://Scripts/Maps.gd")
	draw_grid()
	draw_terrain()
	setupMatch()

func setupMatch():
	draw_units()
	for p in range(len(unitLocations)):
		unitMovements[str(p+1)] = []
		unitDirections.push_back(0)
		unitHealth.push_back(Units.getMaxHealthOfUnit(unitType[p]))
	
func clearMove(val):
	if val in unitMovements:
		for p in unitMovements[val]:
			nodeArr[(p.x - 1) * grid_height + (p.y-1)].clearWalk()
		unitMovements[val] = []
	
	if val in unitAttacks && unitAttacks[val]:
		var p = unitAttacks[val]
		nodeArr[(p.x - 1) * grid_height + (p.y-1)].clearAttack()
		unitAttacks[val] = null
		
func draw_grid():
	for i in range(grid_width):
		for j in range(grid_height):
			var tile = Tile.instance()
			tile.pColors = pColors
			tile.x = i + 1
			tile.y = j + 1
			tile.name = str(i*grid_height + j)
			tile.Board = self
			tile.position = Vector2(offset*i, -offset*j)
			nodeArr.push_back(tile)
			$Tiles.add_child(tile)

func getMaxMovement():
	var maxMoveForUnit = Units.getMaxMovementOfUnit(unitType[int(currPiece) - 1])
	return maxMoveForUnit

func setMaxMovement():
	var maxMoveForUnit = Units.getMaxMovementOfUnit(unitType[int(currPiece) - 1])
	movement = maxMoveForUnit
	return movement

func getOwner(id):
	return unitOwners[int(id)-1]

func walk(pos): #check if piece can walk onto specified location
	var moveDist = abs(pos.x - currPieceLoc.x) + abs(pos.y - currPieceLoc.y)
	if moveDist > 1 || (pos in terrainArr):
		return false
	for uk in unitMovements.keys():
		#only check movement w same team, enemy collision resolves during timeout function
		if getOwner(currPiece) == getOwner(uk):
			#check if we collide w a move on same team
			if uk != currPiece && unitMovements[uk].size() >= getMaxMovement() + 1 - movement:
				if unitMovements[uk][getMaxMovement() - movement] == pos:
					return false
	unitMovements[currPiece].push_back(pos)
	if unitMovements[currPiece].size() > maxMoveInTurn:
		maxMoveInTurn = unitMovements[currPiece].size()
	currPieceLoc = pos
	return true

func attack(pos): #check if piece can call an attack onto specified location
	var attDist = abs(pos.x - currPieceLoc.x) + abs(pos.y - currPieceLoc.y)
	var range_idx = unitType[int(currPiece) - 1]
	if attDist > Units.getMaxRangeOfUnit(range_idx):
		return false
	unitAttacks[currPiece] = pos
	return true

func draw_terrain():
	terrainArr = Map.getTerrain()
	for t in terrainArr:
		nodeArr[(t.x-1) * grid_height + (t.y-1)].showTerrain()
	
func draw_units():
	var count = 1
	for p in unitLocations:
		var unit = Sprite.new()
		unit.modulate = pColors[unitOwners[count-1]-1]
		unit.texture = load("res://Assets/Tanks/" + Units.getImageOfUnit(unitType[count-1]))
		unit.position = Vector2(offset*(p.x-1), -offset*(p.y-1))
		nodeArr[(p.x-1) * grid_height + (p.y-1)].piece = str(count)
		$Units.add_child(unit)
		unitArr.push_back(unit)
		count += 1
		
func clear_units():
	pass
		
func deselectCurrPiece():
	var currPos = unitLocations[int(currPiece)-1]
	nodeArr[(currPos.x-1) * grid_height + (currPos.y-1)].deselect()
		
func currentTile(curr):
	if currTile && currTile != curr:
		currTile.deselect()
	currTile = curr

func endTurn():
	currMoveInTurn = 1
	if phase == Phases.MVMT:
		animationTimer = basicTimerScript.makeTimer(.4, self, "_moveAnimationTimerTimeout", false)
		add_child(animationTimer)
	elif phase == Phases.CMBT:
		resolveCombat()
		phase = Phases.MVMT
		pcamera.updatePhaseText("PHASE: MOVEMENT")
		
func _moveAnimationTimerTimeout():
	var unitCtr = 1
	#simulate movement to prevent collisions
	var nextMoveLocations = {}
	for u in unitLocations:
		var moves = unitMovements[str(unitCtr)]
		for idx in range(moves.size()):
			var currPos = unitLocations[unitCtr-1]
			if idx == currMoveInTurn-1:
				var m = moves[idx]
				#move piece
				nextMoveLocations[unitCtr-1] = m #set active location to m
		unitCtr += 1
			
	#check unit collision using double for loop
	for nk in nextMoveLocations.keys():
		for otherKey in nextMoveLocations.keys():
			if (otherKey != nk) && (nextMoveLocations[nk] == nextMoveLocations[otherKey]):
				#clear grid of moves for all collided pieces
				for m in unitMovements[str(otherKey+1)]:
					nodeArr[(m.x - 1) * grid_height + (m.y - 1)].clearWalk()
				for m in unitMovements[str(nk+1)]:
					nodeArr[(m.x - 1) * grid_height + (m.y - 1)].clearWalk()
				unitMovements[str(otherKey+1)] = []
				unitMovements[str(nk+1)] = []

	#advance all pieces sequentially (everyone moves 1 step forward)
	unitCtr = 1
	for u in unitLocations:
		var moves = unitMovements[str(unitCtr)]
		for idx in range(moves.size()):
			var currPos = unitLocations[unitCtr-1]
			if idx == currMoveInTurn-1:
				var m = moves[idx]
				#check for rotation update
				updatePieceRotation(unitCtr, unitLocations[unitCtr - 1], m)
				#move piece
				unitArr[unitCtr-1].position = getPosFromVec(m) #move unit
				unitLocations[unitCtr-1] = m #set active location  to m
				nodeArr[(m.x - 1) * grid_height + (m.y - 1)].clearWalk()
		
		#tell new tile it has a piece on it
		nodeArr[(unitLocations[unitCtr-1].x-1) * grid_height + (unitLocations[unitCtr-1].y-1)].piece = str(unitCtr)
		unitCtr += 1
		
	#check if unit move finished
	currMoveInTurn += 1
	if currMoveInTurn > maxMoveInTurn:
		for p in range(len(unitLocations)):
			unitMovements[str(p+1)] = []
		maxMoveInTurn = 0
		phase = Phases.CMBT
		pcamera.updatePhaseText("PHASE: COMBAT")
		clearBoardAfterMovement()
		animationTimer.queue_free()
		#Bug where fog does not properly update unnless cleared
		updateBoardFog(false)
		updateBoardFog(true)
		
func clearBoardAfterMovement():
	for i in range(grid_height * grid_width):
		nodeArr[i].piece = null
	
	for i in range(len(unitLocations)):
		nodeArr[(unitLocations[i].x - 1) * grid_height + (unitLocations[i].y - 1)].piece = str(i+1)
		
func updatePieceRotation(counter, currPos, newPos):
	if currPos.x != newPos.x:
		unitArr[counter-1].rotation = (int(newPos.x - currPos.x)%2 * PI/2)
		if int(newPos.x - currPos.x)%2 > 0:
			unitDirections[counter-1] = 1
		else:
			unitDirections[counter-1] = 3
	elif currPos.y != newPos.y:
		unitArr[counter-1].rotation = (int(newPos.y - currPos.y)%2 * PI/2 - PI/2)
		if int(newPos.y - currPos.y)%2 > 0:
			unitDirections[counter-1] = 0
		else:
			unitDirections[counter-1] = 2
		
func resolveCombat():
	var combatPrio = assignCombatPriorities()
	var sortedCombatKeys = combatPrio.keys()
	sortedCombatKeys.sort()
	
	for attacks in sortedCombatKeys:
		var attacksThisTurn = combatPrio[attacks]
		for id in attacksThisTurn:
			var targetLocation = unitAttacks[id]
			if targetLocation:
				if targetLocation in unitLocations:
					var hitID = unitLocations.find(targetLocation)
					var damageAmount = Units.getDamageOfUnit(unitType[int(id)-1])
					unitHealth[hitID] -= damageAmount
				unitAttacks[id] = null
		for id in unitAttacks:
			if unitHealth[int(id)-1] <= 0:
				unitAttacks[id] = null
	for i in range(grid_width):
		for j in range(grid_height):
			nodeArr[i * grid_height + j].clearAttack()
	unitAttacks = {}
	removeDeadUnits()
		
func assignCombatPriorities():
	var priorityD = {}
	for id in unitAttacks.keys():
		var attackAngle = calculateAngle(unitLocations[int(id)-1], unitDirections[int(id)-1], unitAttacks[id])
		if attackAngle in priorityD:
			priorityD[attackAngle].push_back(id)
		else:
			priorityD[attackAngle] = [id]
	return priorityD
	
#pos1 and dir are attributes of first tank, pos2 is attacking location
func calculateAngle(pos1, dir, pos2):
	var vec1 = dirUnitVecs[dir]
	var vec2 = (pos2 - pos1).normalized()
	var angle = int(pow(10, degreesOfFreedom) * acos(vec1.dot(vec2))*180/PI)
	return angle
		
func removeDeadUnits():
	var fullPass = true
	var offset = 0
	while(fullPass):
		fullPass = true
		for id in range(len(unitLocations)):
			if unitHealth[id] <= 0:
				nodeArr[(unitLocations[id].x - 1) * grid_height + (unitLocations[id].y - 1)].piece = null
				unitArr[id].queue_free()
				unitLocations.remove(id)
				unitOwners.remove(id)
				unitType.remove(id)
				unitHealth.remove(id)
				unitArr.remove(id)
				fullPass = false
				offset += 1
				break
				
		fullPass = !fullPass
			
	unitMovements = {}
	for id in range(len(unitLocations)):
		unitMovements[str(id+1)] = []
		var currLoc = unitLocations[id]
		nodeArr[(currLoc.x - 1) * grid_height + (currLoc.y - 1)].piece = str(id + 1)
		
func getPosFromVec(v):
	return Vector2((v.x - 1) * offset, -1 * (v.y - 1) * offset)

func playSound1():
	$Audio.stream = load("res://Assets/Sounds/sound1.wav")
	$Audio.play()
	
func playSound2():
	$Audio.stream = load("res://Assets/Sounds/sound2.wav")
	$Audio.play()

func updateBoardFog(val):
	for i in range(grid_width):
		for j in range(grid_height):
			#if piece is not in a unit view, cover with fog
			var isSeen = false
			for u in range(len(unitOwners)):
				if unitOwners[u] == playerFogView:
					var sightRange = Units.getMaxVisionOfUnit(unitType[u])
					if ( abs(i-unitLocations[u].x+1) + abs(j - unitLocations[u].y+1) ) <= sightRange:
						isSeen = true
						break
			if !val || (val && !isSeen):
				nodeArr[i * grid_width + j].enableFog(val)
				nodeArr[i * grid_width + j].fog = val
