extends Interactable

@export var detection_range: float = 20.0
@export var rotation_speed: float = 5.0  # Higher = faster rotation

var target_player: Node3D = null

func _physics_process(delta):
	target_player = get_closest_player_in_range()

	if target_player:
		look_at_player_y_only(delta)

func get_closest_player_in_range() -> Node3D:
	var players = get_tree().get_nodes_in_group("Player")
	var closest = null
	var min_distance = detection_range

	for player in players:
		if not player is Node3D:
			continue
		var dist = global_transform.origin.distance_to(player.global_transform.origin)
		if dist <= min_distance:
			min_distance = dist
			closest = player

	return closest

func look_at_player_y_only(delta: float):
	var self_pos = global_transform.origin
	var target_pos = target_player.global_transform.origin

	# Flatten to Y-axis (ignore vertical difference)
	target_pos.y = self_pos.y

	var current_facing = -transform.basis.z
	var desired_direction = (target_pos - self_pos).normalized()

	# Get angle difference around Y axis
	var angle_diff = current_facing.signed_angle_to(desired_direction, Vector3.UP)

	# Apply angular velocity for smooth rotation
	angular_velocity = Vector3.UP * angle_diff * rotation_speed
	
func action_use(wants_grab := false):
	get_tree().change_scene_to_file("res://Scenes/Level/KillScene.tscn")
