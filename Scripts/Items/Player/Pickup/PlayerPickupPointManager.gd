extends Node3D

var can_throw := false
@onready var player = get_node("../../")
@onready var camera = player.get_node("Camera3D")

func _process(delta):
	# Only throw if we're holding something and throwing is enabled
	if Input.is_action_just_pressed("Grab") and get_child_count() > 0 and can_throw:
		throw_held_object()

func throw_held_object():
	var held_object = get_child(0)

	# Detach from PickupPoint and reparent to world or player's parent
	remove_child(held_object)
	player.get_parent().add_child(held_object)
	held_object.global_transform = global_transform

	# Reactivate physics
	if held_object is RigidBody3D:
		var throw_force = 10.0
		held_object.freeze = false
		held_object.gravity_scale = 1
		if held_object.has_node("CollisionShape3D"):
			held_object.get_node("CollisionShape3D").disabled = false

		var forward = -camera.global_transform.basis.z.normalized()
		held_object.apply_impulse(forward * throw_force)

	# Reset throw permission
	can_throw = false

	# Allow object to become pickable again
	if held_object.has_method("reset_pickup_state"):
		held_object.reset_pickup_state()

func enable_throw():
	can_throw = true
