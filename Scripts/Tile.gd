extends Area2D

enum Phases{
	SELECT,
	MVMT, MVMT_RSLTN,
	CMBT, CMBT_RSLTN
}

var pColors
var active = false #this piece is selected, starts false
var walked = false
var attacked = false
var fog = false
var Board = null
var pcamera = null
var Units
var x = -1
var y = -1

var piece = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$MoveNumber.add_color_override("font_color", Color(1, 0, 0, 0))
	Units = load("res://Scripts/Units.gd")

func _on_Tile_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.button_index == 1 && event.pressed && !fog):
		if Board.phase == Phases.SELECT:
			if posInPlayerSpawn():
				Board.playSound1()
				pcamera.showSelectUnitInfo()
				Board.setUnitSpawn(Vector2(x, y))
			else:
				return false
		elif Board.walking:
			if Board.walk(Vector2(x, y)):
				walk()
				Board.playSound1()
			else:
				Board.playSound2() #invalid walk selection
		elif Board.attacking:
			if Board.attack(Vector2(x, y)):
				attack()
				Board.playSound1()
			else:
				Board.playSound2()
		else:
			select()

func posInPlayerSpawn():
	var playerSpawn = Board.getSpawn()
	if Vector2(x, y) in playerSpawn:
		return true
	else:
		false

func walk():
	if Board.movement > 0:
		$MoveNumber.text = str(Board.getMaxMovement() + 1 - Board.movement)
		walked = true
		Board.movement -= 1
		colorWalk()
		$Background.show()
		
		if Board.movement == 0:
			Board.walking = false
			Board.deselectCurrPiece()
	else:
		Board.walking = false

func attack():
	colorAttack()
	attacked = true
	$Background.show()
	Board.deselectCurrPiece()
	Board.attacking = false

func select():
	if !active:
		if piece && Board.phase == Phases.MVMT:
			Board.clearMove(piece)
			Board.currPiece = piece
			Board.currPieceLoc = Vector2(x, y)
			Board.movement = Board.setMaxMovement()
			Board.walking = true
			$Glow.self_modulate = pColors[Board.unitOwners[int(piece) - 1] - 1]
		elif piece && Board.phase == Phases.CMBT:
			var unitId = Board.unitType[int(piece)-1]
			print("Possible attacks for unit ", Units.getNameOfUnit(unitId), " are ", Units.getAbilities(unitId))
			Board.clearMove(piece)
			Board.currPiece = piece
			Board.currPieceLoc = Vector2(x, y)
			Board.attacking = true
			$Glow.self_modulate = pColors[Board.unitOwners[int(piece) - 1] - 1]
		else:
			$Glow.self_modulate = Color(1, 1, 1)
		active = true
		Board.currentTile(self)
		$Glow.show()
		Board.playSound1()
	else:
		deselect()
		Board.playSound2()

func deselect():
	if walked:
		colorWalk()
	elif attacked:
		colorAttack()
	$Glow.hide()
	active = false

func clearWalk():
	$Background.hide()
	$MoveNumber.clear()
	walked = false

func colorWalk():
	$Background.self_modulate = Color(1, 1, 1)

func colorTile(col):
	$Background.self_modulate = col
	$Background.show()

func uncolorTile():
	$Background.self_modulate = Color(1, 1, 1)
	$Background.hide()

func colorAttack():
	$Background.self_modulate = Color(1, 0, 0)

func clearAttack():
	$Background.hide()
	attacked = false
	
func enableFog(val):
	if val:
		$Fog.show()
	else:
		$Fog.hide()

func showTerrain():
	$Terrain.show()
