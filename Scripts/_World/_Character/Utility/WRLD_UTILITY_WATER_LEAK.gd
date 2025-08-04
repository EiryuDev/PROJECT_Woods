extends Node3D

@export var target_scale: Vector3 = Vector3(1,1,1)
@export var rise_time: float = 2.0
@export var stay_time: float = 2.2
@export var fall_time: float = 2.3

var tween: Tween

func _ready():
	scale = Vector3.ZERO

func start_water_effect():
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, rise_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_water_fully_extended"))
	
func _on_water_fully_extended():
	await get_tree().create_timer(stay_time).timeout
	var down_tween = create_tween()
	down_tween.tween_property(self, "scale", Vector3.ZERO, fall_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
