extends Node3D

@onready var playerLocomotionManager : PlayerLocomotionManager = get_parent()

@onready var stepSounds = $StepSounds

@export var stepAfterDistance = 1.0
@onready var lastPos = global_position
var distanceTravelledSinceLastStep = 0.0

func _physics_process(delta):
	if !playerLocomotionManager.characterBody.is_on_floor():
		distanceTravelledSinceLastStep = 0.0
	
	distanceTravelledSinceLastStep += global_position.distance_to(lastPos)
	if distanceTravelledSinceLastStep >= stepAfterDistance:
		distanceTravelledSinceLastStep = 0.0
		stepSounds.play()
	
	lastPos = global_position
