extends Node2D


var Board = load("res://Scenes/Board.tscn")
var PCamera = load("res://Scenes/PCamera.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var board = Board.instance()
	var pcamera = PCamera.instance()
	board.pcamera = pcamera
	pcamera.Board = board
	call_deferred("add_child", board)
	board.call_deferred("add_child", pcamera)
	
	#start game, ask two players to load in
	
	#spawn map and ask players for positions
	
	#take simultaneous movement then combat turns
	
	#end once someone is wiped, or concedes


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
