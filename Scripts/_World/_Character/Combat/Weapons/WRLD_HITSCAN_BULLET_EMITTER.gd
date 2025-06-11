extends BulletEmitter

@onready var raycast3D = $RayCast3D
var bulletHitEffect = preload("res://Resources/Prefabs/VFX Objects/Weapons/BulletHitEffect.tscn")

func SetBodiesToExclude(bodies: Array):
	super(bodies) 
	for body in bodies:
		raycast3D.add_exception(body)
		
func Fire():
	raycast3D.enabled = true
	raycast3D.force_raycast_update()
	if raycast3D.is_colliding():
		if raycast3D.get_collider().has_method("Hurt"):
			var damageData = DamageData.new()
			damageData.amount = damage
			damageData.hitPos = raycast3D.get_collision_point()
			raycast3D.get_collider().hurt(damageData)
		else:
			var hitEffect : Node3D = bulletHitEffect.instantiate()
			get_tree().get_root().add_child(hitEffect)
			var hitPos : Vector3 = raycast3D.get_collision_point() 
			var hitNormal : Vector3 = raycast3D.get_collision_normal()
			var lookAtPosition : Vector3 = hitPos + hitNormal
			hitEffect.global_position = hitPos
			if hitNormal.is_equal_approx(Vector3.UP) or hitNormal.is_equal_approx(Vector3.DOWN):
				hitEffect.look_at(lookAtPosition, Vector3.RIGHT)
			else:
				hitEffect.look_at(lookAtPosition)
	raycast3D.enabled = false
	super()
	
