extends Node3D

@export var max_tilt_angle_deg: float = 5.0  # Max rotation in degrees
@export var rotation_speed: float = 5.0      # Speed of rotation
@export var parallaxEffect = true

func _process(delta):
	if !parallaxEffect:
		return
		
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()

	# Normalize to range [-1, 1]
	var offset = (mouse_pos / viewport_size) * 2.0 - Vector2.ONE
	offset.y *= -1.0  # Invert Y to match typical camera behavior

	# Convert to radians and apply limits
	var target_rot_x = deg_to_rad(offset.y * max_tilt_angle_deg)
	var target_rot_y = deg_to_rad(offset.x * max_tilt_angle_deg)

	# Smooth rotation using spherical interpolation (for 3D)
	var target_basis = Basis()
	target_basis = target_basis.rotated(Vector3(1, 0, 0), target_rot_x)
	target_basis = target_basis.rotated(Vector3(0, 1, 0), target_rot_y)

	# Interpolate to target rotation smoothly
	global_transform.basis = global_transform.basis.slerp(target_basis, delta * rotation_speed)
