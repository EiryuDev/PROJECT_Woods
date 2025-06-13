extends Node  # Or whatever type your child node actually is (Node3D, Area3D, etc.)
@onready var characterBody = get_parent() as CharacterBody3D

# === Movement Settings ===
@export_group("Walk Settings")
@export var SPEED = 5.0

# === Sprint Settings ===
@export_group("Sprint Settings")
@export var sprintSpeed = 2.0
var is_sprinting = false

# === Jump Settings ===
@export_group("Jump Settings")
const JUMP_VELOCITY = 4.5

# === Slide Settings ===
@export_group("Slide Settings")
const SLIDE_SPEED = 10.0
const SLIDE_DURATION = 0.5
const SLIDE_COOLDOWN = 1.0
var is_sliding = false
var slide_timer = 0.0
var slide_cooldown_timer = 0.0

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
@onready var player_collision_shape = $"../CollisionShape3D"
@onready var camera_start_pos = $"../Camera3D".position
@onready var player = $".."
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal moved(velocity: Vector3, grounded: bool)

func _input(event):
	if player.isDead:
		return
		
	if event is InputEventMouseMotion:
		characterBody.rotation.y -= mouse_sens * event.relative.x * 0.001  # Convert to radians
		camera.rotation.x -= mouse_sens * event.relative.y * 0.001
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func StopMovement():
	# Completely stops player movement by zeroing velocity.
	if characterBody:
		characterBody.velocity = Vector3.ZERO
		characterBody.move_and_slide()

func _physics_process(delta):
	if !characterBody:
		return  # Safety check
	
	if player.isDead:
		return

	# Add gravity
	if not characterBody.is_on_floor():
		characterBody.velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and characterBody.is_on_floor():
		characterBody.velocity.y = JUMP_VELOCITY

	# Handle crouch (disables sprinting when crouching)
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

	# Handle sprint (only if not crouching)
	is_sprinting = Input.is_action_pressed("sprint") and !is_crouching

	# Handle slide
	if Input.is_action_just_pressed("slide") and !is_sliding and slide_cooldown_timer <= 0.0:
		is_sliding = true
		slide_timer = 0.0

	# Get movement input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (characterBody.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Slide movement logic
	if is_sliding:
		slide_timer += delta
		if slide_timer <= SLIDE_DURATION:
			print("Sliding my guy")
			characterBody.velocity.x = direction.x * SLIDE_SPEED
			characterBody.velocity.z = direction.z * SLIDE_SPEED
		else:
			is_sliding = false
			slide_cooldown_timer = SLIDE_COOLDOWN

	# Slide cooldown timer
	if slide_cooldown_timer > 0.0:
		slide_cooldown_timer -= delta

	# Calculate current speed based on state
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

	characterBody.move_and_slide()  # Call on parent, not self
	moved.emit(characterBody.velocity, characterBody.is_on_floor())
