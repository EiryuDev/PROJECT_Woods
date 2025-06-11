extends Marker3D

var bulletHitEffect = preload("res://Resources/Prefabs/VFX Objects/Weapons/BulletHitEffect.tscn")
var spawnRate = 3.0
var spawnTime = 0.0

func _process(delta):
	spawnTime -= delta
	if spawnTime < 0.0:
		spawnTime = spawnRate
		var effect = bulletHitEffect.instantiate()
		effect.global_transform = global_transform
		get_tree().get_root().add_child(effect)
