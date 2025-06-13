extends BulletEmitter

@onready var losRaycast = $LOSRaycast
@export var attackRadius := 1.0

@export var offsetByRadius = false

func Fire():
	var queryParams := PhysicsShapeQueryParameters3D.new()
	queryParams.shape = SphereShape3D.new()
	queryParams.shape.radius = attackRadius
	queryParams.collision_mask = 2 
	var tr = global_transform
	if offsetByRadius:
		tr.origin = to_global(Vector3.FORWARD* attackRadius)
	queryParams.transform = tr
	queryParams.exclude = bodiesToExclude
	var intersectResults : Array[Dictionary] = get_world_3d().direct_space_state.intersect_shape(queryParams, 100)
	for intersectData in intersectResults:
		var collider : Node3D = intersectData.collider
		if collider.has_method("Hurt") and HasLOS(collider):
			var damageData = DamageData.new()
			damageData.amount = damage
			damageData.hitPos = collider.global_position + Vector3.UP
			collider.Hurt(damageData)
	super()

func HasLOS(collider: Node3D) -> bool:
	losRaycast.enabled = true
	losRaycast.target_position = losRaycast.to_local(collider.global_position + Vector3.UP)
	losRaycast.force_raycast_update()
	var inLOS = !losRaycast.is_colliding()
	losRaycast.enabled = false
	return inLOS
	
	
	
