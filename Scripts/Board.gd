extends Node2D

enum Phases{
	MVMT, MVMT_RSLTN,
	CMBT, CMBT_RSLTN
}

export (int) var grid_width = 16
export (int) var grid_height = 8
export var offset = 55

var currTile = null
var Tile = load("res://Scenes/Tile.tscn")
export var maxMove = 4
export var maxRange = 4

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

var nodeArr = []
var unitArr = []

var unitLocations = [Vector2(1, 1), Vector2(2, 4)]
var unitDirections = [] # 0, 1, 2, 3 -> N, E, S, W
var unitMovements =  {} #0th element in array is unit 1 here
var unitAttacks   =  {} #same layout as movements, key: id, val: Vec2 pos

# Called when the node enters the scene tree for the first time.
func _ready():
	basicTimerScript = load("res://Scripts/BasicTimer.gd")
	draw_grid()
	draw_units()
	for p in range(len(unitLocations)):
		unitMovements[str(p+1)] = []
		unitAttacks[str(p+1)] = null
		unitDirections.push_back(0)
	
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
			tile.x = i + 1
			tile.y = j + 1
			tile.name = str(i*grid_height + j)
			tile.Board = self
			tile.position = Vector2(offset*i, -offset*j)
			nodeArr.push_back(tile)
			$Tiles.add_child(tile)

func walk(pos): #check if piece can walk onto specified location
	var moveDist = abs(pos.x - currPieceLoc.x) + abs(pos.y - currPieceLoc.y)
	if moveDist > 1:
		return false
	for uk in unitMovements.keys():
		if uk != currPiece && unitMovements[uk].size() >= 5 - movement:
			if unitMovements[uk][4 - movement] == pos:
				return false
	unitMovements[currPiece].push_back(pos)
	if unitMovements[currPiece].size() > maxMoveInTurn:
		maxMoveInTurn = unitMovements[currPiece].size()
	currPieceLoc = pos
	return true

func attack(pos): #check if piece can call an attack onto specified location
	var attDist = abs(pos.x - currPieceLoc.x) + abs(pos.y - currPieceLoc.y)
	if attDist > 3:
		return false
	unitAttacks[currPiece] = pos
	return true

func draw_units():
	var count = 1
	for p in unitLocations:
		var unit = Sprite.new()
		unit.texture = load("res://Assets/pointer.png")
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
		phase = Phases.MVMT
		pcamera.updatePhaseText("PHASE: MOVEMENT")
		
func _moveAnimationTimerTimeout():
	var unitCtr = 1
	#advance all pieces sequentially (everyone moves 1 step forward)
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
		animationTimer.queue_free()
		phase = Phases.CMBT
		pcamera.updatePhaseText("PHASE: COMBAT")
		
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
		
func getPosFromVec(v):
	return Vector2((v.x - 1) * offset, -1 * (v.y - 1) * offset)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
