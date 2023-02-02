extends Node


const HP_ARR  = [5, 5, 5, 5, 5]
const RNG_ARR = [1, 1, 1, 1, 1]
const MVE_ARR = [2, 2, 2, 2, 2]
const VIS_ARR = [4, 4, 4, 4, 4]
const DMG_ARR = [5, 5, 5, 5, 5]
const IMG_ARR = ["elektro.png", "wally.png", "badgundam.png", "howls.png", "roadster.png"]
const NAME_ARR = ["ELEKTRO", "WALLY", "BUNDAM", "HOWL", "RDSTR"]

# Called when the node enters the scene tree for the first time.
func _ready():
	#set functions into array
	pass

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

static func getNameOfUnit(id):
	return idSearch(id, NAME_ARR, "?")

static func idSearch(id, arr, default):
	id = int(id)
	if id <= len(arr):
		return arr[id-1]
	else:
		return default

static func getAbilities(id):
	id = int(id)
	
	var ability_dict = {
		1 : [],
		2 : ["attack_trashmaker"],
		3 : [],
		4 : [],
		5 : []
	}
	
	if !(id in ability_dict):
		print("Abilities not found for unit ", id)
		return []
	else:
		return ability_dict[id]
