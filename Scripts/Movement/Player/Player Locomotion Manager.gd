class_name PlayerLocomotionManager
extends Node

@onready var characterBody = get_parent() as CharacterBody3D
@onready var playerStatsManager = %"Player Stats Manager"

# === Movement Settings ===
@export_group("Walk Settings")
@export var SPEED = 5.0

# === Head Bobbing ===
@export_group("Head Bob Settings")
var _delta := 0.0
@export var camBobSpeed := 10.0
@export var camBobUpDown := 1.0
var origCamPos := Vector3.ZERO

# === Sprint Settings ===
@export_group("Sprint Settings")
@export var sprintSpeed = 2.0
@export var sprintStaminaPerSecond = 5.0
var is_sprinting = false

# === Jump Settings ===
@export_group("Jump Settings")
@export var jumpStamina = 10
const JUMP_VELOCITY = 4.5

# === Crouch Settings ===
@export_group("Crouch Settings")
@export var crouch_height = 1.0
@export var stand_height = 2.0
@export var crouch_speed_multiplier = 0.5
var is_crouching = false

# === Mouse Settings ===
@export_group("Mouse Settings")
@export var mouse_sens = 0.5

# === Nodes and Physics ===
@onready var camera = $"../Camera3D"
@onready var viewportCamera = get_node("%ViewportCamera")
@onready var player_collision_shape = $"../CollisionShape3D"
@onready var camera_start_pos = camera.position
@onready var player = $".."
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal moved(velocity: Vector3, grounded: bool)

func _ready():
	origCamPos = camera.position

func _process(delta):
	viewportCamera.set_global_transform(camera.get_global_transform())

func _input(event):
	if player.isDead:
		return
		
	#if !player.canMove:
		#return
		
	if event is InputEventMouseMotion:
		characterBody.rotation.y -= mouse_sens * event.relative.x * 0.001
		camera.rotation.x -= mouse_sens * event.relative.y * 0.001
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func StopMovement():
	if characterBody:
		characterBody.velocity = Vector3.ZERO
		characterBody.move_and_slide()

func _physics_process(delta):
	if !characterBody:
		return

	if player.isDead:
		return
	
	if(player.canMove):
		GroundedMovement(delta)
	
	process_camBob(delta)

func GroundedMovement(delta):
	# Add gravity
	if not characterBody.is_on_floor():
		characterBody.velocity.y -= gravity * delta

	# Handle jump
	if playerStatsManager.currentStamina >= jumpStamina:
		if Input.is_action_just_pressed("jump") and characterBody.is_on_floor():
			characterBody.velocity.y = JUMP_VELOCITY
			if playerStatsManager.currentStamina >= 0:
				playerStatsManager.hurtStamina(jumpStamina)
			if has_node("JumpSound"):
				$JumpSound.play()

	# Handle crouch
	if Input.is_action_pressed("crouch"):
		if not is_crouching:
			is_crouching = true
			player_collision_shape.shape.height = crouch_height
			camera.position.y = camera_start_pos.y * (crouch_height / stand_height)
	else:
		if is_crouching:
			is_crouching = false
			player_collision_shape.shape.height = stand_height
			camera.position.y = camera_start_pos.y

	# Determine sprint
	var can_sprint = Input.is_action_pressed("sprint") and !is_crouching and playerStatsManager.currentStamina >= sprintStaminaPerSecond * delta
	is_sprinting = can_sprint

	# Drain stamina if sprinting
	if is_sprinting:
		if playerStatsManager.currentStamina >= 0:
			playerStatsManager.hurtStamina(sprintStaminaPerSecond * delta)

	# Get movement input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (characterBody.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Current speed
	var current_speed = SPEED
	if is_sprinting:
		current_speed *= sprintSpeed
	if is_crouching:
		current_speed *= crouch_speed_multiplier

	# Apply movement
	if direction:
		characterBody.velocity.x = direction.x * current_speed
		characterBody.velocity.z = direction.z * current_speed
	else:
		characterBody.velocity.x = move_toward(characterBody.velocity.x, 0, SPEED)
		characterBody.velocity.z = move_toward(characterBody.velocity.z, 0, SPEED)

	characterBody.move_and_slide()
	moved.emit(characterBody.velocity, characterBody.is_on_floor())

func process_camBob(delta):
	_delta += delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (characterBody.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var cam_bob
	var objCam
	var is_moving = direction.length() > 0.01 and characterBody.is_on_floor()

	if player.canMove:
		if is_sprinting:
			cam_bob = floor(abs(direction.z) + abs(direction.x)) * _delta * camBobSpeed * 1.5
			objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobUpDown
		elif is_moving:
			cam_bob = floor(abs(direction.z) + abs(direction.x)) * _delta * camBobSpeed
			objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobUpDown
		else:
			# Idle bob if standing still
			cam_bob = floor(abs(1) + abs(1)) * _delta * 0.6
			objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobUpDown * 0.1
	else:
		# Idle bob only
		cam_bob = floor(abs(1) + abs(1)) * _delta * 0.6
		objCam = origCamPos + Vector3.UP * sin(cam_bob) * camBobUpDown * 0.1

	camera.position = camera.position.lerp(objCam, delta)
