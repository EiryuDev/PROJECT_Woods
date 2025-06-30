extends Node3D

var canLock = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$SpringArm3D.add_excluded_object(get_parent())

func _input(event):
	if $SpringArm3D/CameraOffset/Camera3D.current:
		
		if Input.is_action_just_pressed("ESC"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion and not canLock:
				rotation_degrees.x = clamp(rotation_degrees.x - event.relative.y * 0.1, -70, 70)
				rotation_degrees.y -= event.relative.x * 0.1
				
func _physics_process(delta):
	if $SpringArm3D/CameraOffset/Camera3D.current:
		
		if Input.is_action_just_pressed("TAB"):
			canLock = !canLock
				
		if canLock:
			rotation.x = lerp_angle(rotation.x, 0, 0.1)
			rotation.y = lerp_angle(rotation.y, 0, 0.1)
			
		# Shoulder switching with RMB
		var target_offset_x = 1.0 if Input.is_action_pressed("RMB") else 0.0
		var target_length = 3.0 if Input.is_action_pressed("RMB") else 5.0

		# Lerp side offset and arm length
		var current_offset = $SpringArm3D/CameraOffset.position
		current_offset.x = lerp(current_offset.x, target_offset_x, 0.1)
		$SpringArm3D/CameraOffset.position = current_offset

		$SpringArm3D.spring_length = lerp($SpringArm3D.spring_length, target_length, 0.1)
