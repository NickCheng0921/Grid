
extends KinematicBody2D

export var min_zoom = .3
export var max_zoom = 2
export var zoom_factor = .1

var Board
var stopPos = Vector2(0, 0)
var mousePos:Vector2
var panSpeed = 3
onready var camera = $Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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


func _on_endTurnButton_button_up():
	Board.endTurn()

func updatePhaseText(val):
	$CanvasLayer/phaseInfo.text = val
