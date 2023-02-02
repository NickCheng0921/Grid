
extends KinematicBody2D

export var min_zoom = .3
export var max_zoom = 2
export var zoom_factor = .1
export var offset = 55

var Board
var Units
var stopPos = Vector2(0, 0)
var mousePos:Vector2
var panSpeed = 3
onready var camera = $Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	Units = load("res://Scripts/Units.gd")
	setupUnitSelection()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		mousePos = get_viewport().get_mouse_position()
	if Input.is_action_pressed("right_click"):
		var currPos = get_viewport().get_mouse_position()
		#mousePos = currPos
		#move_and_slide((mousePos - currPos)*panSpeed, Vector2(0, -1))
		global_position = mousePos - currPos + stopPos
	if Input.is_action_just_released("right_click"):
		stopPos = position
		
	if Input.is_action_just_released("scroll_up"):
		if camera.zoom.x >= min_zoom:
			camera.zoom.x -= zoom_factor
			camera.zoom.y -= zoom_factor
	if Input.is_action_just_released("scroll_down"):
		if camera.zoom.x <= max_zoom:
			camera.zoom.x += zoom_factor
			camera.zoom.y += zoom_factor

func setupUnitSelection():
	for i in range(len(Units.HP_ARR)):
		var button = Button.new()
		var buttonPos = $CanvasLayer/selectInfo.global_position
		
		buttonPos.x += i*offset
		button.margin_left = i*offset
		button.margin_top = 0
		button.margin_right = (i+1)*offset
		button.margin_bottom = 55
		button.connect("button_up", self, "selectedSpawnUnit", [i+1])
		
		var img = Sprite.new()
		img.texture = load("res://Assets/Tanks/" + str(Units.getImageOfUnit(i+1)))
		img.position.x = i*offset + offset/2
		img.position.y += offset/2
		
		var nameLabel = RichTextLabel.new()
		nameLabel.margin_left = i*offset
		nameLabel.margin_top = -15
		nameLabel.margin_right = i*offset + 100
		nameLabel.margin_bottom = 15
		nameLabel.text = Units.NAME_ARR[i]
		
		$CanvasLayer/selectInfo.add_child(button)
		$CanvasLayer/selectInfo.add_child(img)
		$CanvasLayer/selectInfo.add_child(nameLabel)

func showSelectUnitInfo():
	$CanvasLayer/selectInfo.show()

func hideSelectUnitInfo():
	$CanvasLayer/selectInfo.hide()

func showInGameInfo():
	$CanvasLayer/inGameInfo.show()

func selectedSpawnUnit(id):
	Board.spawnUnit(id)
	$CanvasLayer/selectInfo.hide()

func _on_endTurnButton_button_up():
	Board.endTurn()

func updatePhaseText(val):
	$CanvasLayer/phaseInfo.text = val

func _on_playerSwapButton_button_up():
	#if fog, we have to update TODO
	if Board.currPlayer == 1:
		Board.currPlayer = 2
		$CanvasLayer/playerInfo.text = "PLAYER: 2"
	else:
		Board.currPlayer = 1
		$CanvasLayer/playerInfo.text = "PLAYER: 1"
		
	if Board.currFogVal:
		Board.updateBoardFog(false)
		Board.updateBoardFog(Board.currPlayer)

func _on_showFogButton_button_up():
	Board.currFogVal = true
	Board.updateBoardFog(false)
	Board.updateBoardFog(Board.currFogVal)

func _on_hideFogButton_button_up():
	Board.currFogVal = false
	Board.updateBoardFog(Board.currFogVal)
