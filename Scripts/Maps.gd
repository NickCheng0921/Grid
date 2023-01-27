extends Node

const terrain_array = [
	Vector2(5, 5), Vector2(4, 5), Vector2(5, 4)
]

const p1Spawn = [
	Vector2(1, 1), Vector2(2, 1), Vector2(3, 1),
	Vector2(1, 2), Vector2(2, 2), Vector2(3, 2)
]

const p2Spawn = [
	Vector2(6, 8), Vector2(7, 8), Vector2(8, 8),
	Vector2(6, 7), Vector2(7, 7), Vector2(8, 7)
]

static func getTerrain():
	return terrain_array

static func getP1Spawn():
	return p1Spawn
	
static func getP2Spawn():
	return p2Spawn
