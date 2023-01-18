extends Node

static func makeTimer(duration, node, timeoutMethod, oneShot=true):
	var timer = Timer.new()
	timer.autostart = true
	timer.set_one_shot(oneShot)
	timer.wait_time = duration
	timer.connect("timeout", node, timeoutMethod)
	return timer
