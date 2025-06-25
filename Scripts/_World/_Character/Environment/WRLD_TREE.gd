extends Node3D

@export_group("TREE SETTINGS")
@export var swaySpeed: float = 1.5
@export var swayAngle: float = 5.0
@export var swayAxis: Vector3 = Vector3(0, 1, 0)

var time: float = 0.0
var timeOffset: float = 0.0
var originalRotation: Basis

func _ready():
	originalRotation = global_transform.basis
	timeOffset = randf() * TAU
	
func _process(delta):
	time += delta
	var sway = sin(time * swaySpeed + timeOffset) * deg_to_rad(swayAngle)
	var rotatedBasis = originalRotation.rotated(swayAxis, sway)
	global_transform.basis = rotatedBasis
