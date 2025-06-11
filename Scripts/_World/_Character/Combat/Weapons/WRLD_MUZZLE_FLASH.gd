extends Node3D

@export var flashTime := 0.05

var timer : Timer
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = flashTime
	timer.one_shot = true
	timer.timeout.connect(EndFlash)
	hide()
	
func Flash():
	show()
	rotation.z = randf_range(0.0, TAU)
	timer.start()
	
	
func EndFlash():
	hide()
