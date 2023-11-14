extends CharacterBody3D

@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SLIDE_SPEED = 10.0  # Adjust this speed as needed
const SLIDE_DURATION = 0.5  # Adjust the slide duration as needed
const SLIDE_COOLDOWN = 1.0  # Adjust the cooldown duration as needed

@export var mouse_sens = 0.5
@onready var camera = $Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_sprinting = false
var is_sliding = false
var slide_timer = 0.0
var slide_cooldown_timer = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sens * event.relative.x
		camera.rotation_degrees.x -= mouse_sens * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Check if the "shift" action is pressed to determine sprinting.
	is_sprinting = Input.is_action_pressed("sprint")

	# Check if the "ctrl" action is pressed to initiate a slide.
	if Input.is_action_just_pressed("slide") and !is_sliding and slide_cooldown_timer <= 0.0:
		is_sliding = true
		slide_timer = 0.0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Slide mechanic
	if is_sliding:
		slide_timer += delta
		if slide_timer <= SLIDE_DURATION:
			print("Sliding my guy")
			velocity.x = direction.x * SLIDE_SPEED
			velocity.z = direction.z * SLIDE_SPEED
		else:
			is_sliding = false
			slide_cooldown_timer = SLIDE_COOLDOWN

	# Cooldown for slide
	if slide_cooldown_timer > 0.0:
		slide_cooldown_timer -= delta

	if direction:
		if is_sprinting:
			velocity.x = direction.x * (SPEED * 2.0)  # Increase speed when sprinting
			velocity.z = direction.z * (SPEED * 2.0)
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
