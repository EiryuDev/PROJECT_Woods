class_name HitBox extends Area3D

@export var weakSpot = false
@export var criticalDamageMultiplier = 2
signal onHurt(damageData: DamageData)

func hurt(damageData: DamageData):
	if weakSpot:
		damageData.amount *= criticalDamageMultiplier
	onHurt.emit(damageData)
