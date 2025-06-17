class_name VisionManager extends Node3D

@export var sightArc = 100.0
@export var maxSightRange = 100.0
@export var alwaysDetectInRage = 2.0

@onready var losRayCast3D = $LOSRayCast3D

func CanSeeTarget(target: CharacterBody3D):
	var targetPosition = target.global_position + Vector3.UP * 1.5
	var directionToTarget = global_position.direction_to(targetPosition)
	var distanceToTarget = global_position.distance_to(targetPosition)
	var fwd = -global_transform.basis.z
	
	if distanceToTarget > maxSightRange:
		return false
	
	if distanceToTarget < alwaysDetectInRage:
		return true
	
	if fwd.angle_to(directionToTarget) > deg_to_rad(sightArc / 2.0):
		return false
	
	losRayCast3D.enabled = true
	losRayCast3D.target_position = losRayCast3D.to_local(targetPosition)
	losRayCast3D.force_raycast_update()
	var hasLOS = !losRayCast3D.is_colliding()
	losRayCast3D.enabled = false
	
	return hasLOS

func IsFacingTarget(target: Node3D):
	var pos = to_local(target.global_position)
	return pos.z < 0.0 and abs(pos.x) < 0.5
