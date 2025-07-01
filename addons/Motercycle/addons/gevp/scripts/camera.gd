extends Camera3D

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 1.5, 0.1)  # Head position on bike
@export var yaw_speed: float = 0.005
@export var mouse_sens: float = 0.5
@export var max_yaw_degrees: float = 60.0  # Look limit: 60° left/right

var target: Node3D
var yaw: float = 0.0
var max_yaw_radians: float

func _ready():
	target = get_node_or_null(target_path)
	if not target:
		push_warning("Target is invalid")
		
	max_yaw_radians = deg_to_rad(max_yaw_degrees)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * yaw_speed * mouse_sens
		yaw = clamp(yaw, -max_yaw_radians, max_yaw_radians)
		rotation.y = yaw
		
func _process(delta):
	if not target:
		return
	
	global_position = target.global_transform.origin + target.global_transform.basis * offset
	
	var base_rotation = target.global_transform.basis.get_euler()
	rotation.y = base_rotation.y + yaw
