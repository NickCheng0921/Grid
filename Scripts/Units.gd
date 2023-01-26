extends Node


const HP_ARR  = [10, 5]
const RNG_ARR = [4, 6]
const MVE_ARR = [4, 2]
const VIS_ARR = [4, 2]
const DMG_ARR = [5, 10]
const IMG_ARR = ["basic.png", "heavy.png"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func getMaxHealthOfUnit(id):
	return idSearch(id, HP_ARR, 10)
	
static func getMaxRangeOfUnit(id):
	return idSearch(id, RNG_ARR, 4)
	
static func getMaxMovementOfUnit(id):
	return idSearch(id, MVE_ARR, 4)

static func getMaxVisionOfUnit(id):
	return idSearch(id, VIS_ARR, 4)

static func getDamageOfUnit(id):
	return idSearch(id, DMG_ARR, 5)

static func getImageOfUnit(id):
	return idSearch(id, IMG_ARR, "basic.png")

static func idSearch(id, arr, default):
	id = int(id)
	if id <= len(arr):
		return arr[id-1]
	else:
		return default
