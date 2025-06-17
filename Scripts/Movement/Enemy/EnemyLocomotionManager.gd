class_name EnemyLocomotionManager extends Node3D

@export var JumpForce = 15.0
@export var gravity = 30.0

@export var maxSpeed = 15.0
@export var moveAcceleration = 4.0
@export var stopDrag = 0.9

var characterBody : CharacterBody3D
var moveDrag = 0.0
var moveDirection : Vector3

signal moved(velocity: Vector3, grounded: bool)

@export var turnSpeed = 300.0
var facingDirection : Vector3

@onready var navigationAgent3D = $NavigationAgent3D
var moving = false

func _ready():
	characterBody = get_parent()
	moveDrag = float(moveAcceleration) / maxSpeed
	facingDirection = -characterBody.global_transform.basis.z

func SetFacingDirection(new_face_dir: Vector3):
	facingDirection = new_face_dir
	facingDirection.y = 0.0

func MoveToPoint(point: Vector3):
	moving = true
	navigationAgent3D.target_position = point

func StopMoving():
	moving = false
	SetMoveDirection(Vector3.ZERO)

func SetMoveDirection(new_moveDirection: Vector3):
	moveDirection = new_moveDirection
	moveDirection.y = 0.0
	moveDirection = moveDirection.normalized()

func Jump():
	if characterBody.is_on_floor():
		if has_node("JumpSound"):
			$JumpSound.play()
		characterBody.velocity.y = JumpForce
		

func _physics_process(delta):
	if characterBody.velocity.y > 0.0 and characterBody.is_on_ceiling():
		characterBody.velocity.y = 0.0
	if not characterBody.is_on_floor():
		characterBody.velocity.y -= gravity * delta
	
	var drag = moveDrag
	if moveDirection.is_zero_approx():
		drag = stopDrag
	
	var flat_velo = characterBody.velocity
	flat_velo.y = 0.0
	characterBody.velocity += moveAcceleration * moveDirection - flat_velo * drag
	
	characterBody.move_and_slide()
	moved.emit(characterBody.velocity, characterBody.is_on_floor())
	
	## MOVEMENT
	if moving:
		SetMoveDirection(navigationAgent3D.get_next_path_position() - global_position)
	
	## FACING
	var fwd = -characterBody.global_transform.basis.z
	var right = characterBody.global_transform.basis.x
	var angle_diff = fwd.angle_to(facingDirection)
	var turn_dir = 1
	if right.dot(facingDirection) > 0:
		turn_dir = -1
	
	var turn_amnt = delta * deg_to_rad(turnSpeed)
	if turn_amnt > angle_diff:
		turn_amnt = angle_diff
	
	characterBody.global_rotation.y += turn_amnt * turn_dir
	
