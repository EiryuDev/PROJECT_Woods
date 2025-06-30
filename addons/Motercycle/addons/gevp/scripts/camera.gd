extends Camera3D

# -- export vars let you tweak in the Inspector --
@export var target_path: NodePath            # drag your motorcycle (Node3D) here
@export var offset: Vector3 = Vector3(0, 2, -6)  # camera sits 2m up, 6m behind by default
@export var yaw_speed: float = 0.005         # how fast mouse X turns the camera
@export var max_yaw_degrees: float = 60      # max left/right look in degrees

# -- internal state --
var target: Node3D
var yaw: float = 0.0                         # current yaw offset, in radians
var max_yaw_radians: float

func _ready():
	# resolve the target node
	target = get_node_or_null(target_path)
	if not target:
		push_warning("Camera script: target_path is invalid")
	# convert clamp angle to radians once
	max_yaw_radians = deg_to_rad(max_yaw_degrees)
	# capture the mouse so we can read relative motion
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#func _input(event):
	#if event is InputEventMouseMotion and target:
		## subtract so rightward mouse (positive x) turns view right
		#yaw -= event.relative.x * yaw_speed
		#yaw = clamp(yaw, -max_yaw_radians, max_yaw_radians)

func _process(delta):
	if not target:
		return
	# rotate the offset around Y by current yaw
	var rotated_offset = offset.rotated(Vector3.UP, yaw)
	# position camera relative to the target’s global position
	global_transform.origin = target.global_transform.origin + rotated_offset
	# always look straight at the target, but only yaw-wise
	look_at(target.global_transform.origin, Vector3.UP)
