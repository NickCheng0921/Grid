extends Area2D

enum Phases{
	MVMT, MVMT_RSLTN,
	CMBT, CMBT_RSLTN
}

var pColors
var active = false #this piece is selected, starts false
var walked = false
var attacked = false
var Board = null
var x = -1
var y = -1

var piece = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$MoveNumber.add_color_override("font_color", Color(1, 0, 0, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Tile_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.button_index == 1 && event.pressed):
		if Board.walking:
			if Board.walk(Vector2(x, y)):
				walk()
			else:
				pass #invalid walk selection
		elif Board.attacking:
			if Board.attack(Vector2(x, y)):
				attack()
			else:
				pass
		else:
			select()

func walk():
	if Board.movement > 0:
		$MoveNumber.text = str(5 - Board.movement)
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
			Board.movement = Board.maxMove
			Board.walking = true
			$Background.self_modulate = pColors[Board.unitOwners[int(piece) - 1] - 1]
		elif piece && Board.phase == Phases.CMBT:
			Board.clearMove(piece)
			Board.currPiece = piece
			Board.currPieceLoc = Vector2(x, y)
			Board.attacking = true
			$Background.self_modulate = pColors[Board.unitOwners[int(piece) - 1] - 1]
		else:
			$Background.self_modulate = Color(1, 1, 1)
		active = true
		Board.currentTile(self)
		$Background.show()
	else:
		deselect()

func deselect():
	if walked:
		colorWalk()
	elif attacked:
		colorAttack()
	else:
		$Background.hide()
	active = false

func clearWalk():
	$Background.hide()
	$MoveNumber.clear()
	walked = false

func colorWalk():
	$Background.self_modulate = Color(1, 1, 1)

func colorAttack():
	$Background.self_modulate = Color(1, 0, 0)

func clearAttack():
	$Background.hide()
	attacked = false
	
