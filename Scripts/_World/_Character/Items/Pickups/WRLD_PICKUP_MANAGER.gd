class_name Pickup extends Area3D

enum PICKUP_TYPES {HEALTH, WEAPON, AMMO}
enum WEAPONS {DEAGLE}
@export var pickupType = PICKUP_TYPES.HEALTH
@export var weaponType = WEAPONS.DEAGLE
@export var pickupAmount = 20

func Pickup():
	queue_free()
