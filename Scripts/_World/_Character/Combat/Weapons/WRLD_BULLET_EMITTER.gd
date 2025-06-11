extends Node3D

class_name BulletEmitter
var bodiesToExclude = []
var damage = 1

func SetDamage(d: int):
	damage = d
	for child in get_children():
		if child is BulletEmitter:
			child.SetDamage(d)
			
func SetBodiesToExclude(bodies: Array):
	bodiesToExclude = bodies
	for child in get_children():
		if child is BulletEmitter:
			child.SetBodiesToExclude(bodies)

func Fire():
	for child in get_children():
		if child is BulletEmitter:
			child.Fire()
