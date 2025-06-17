class_name Enemy extends CharacterBody3D

@onready var statsManager = $"Stats Manager"
@onready var visionManager = $"Vision Manager"
@onready var locomotionManager = $LocomotionManager
@onready var attackEmitter = $AttackEmitter

@onready var nearbyMonstersAlertArea = $NearbyMonstersAlertArea
@export var animationPlayer : AnimationPlayer

@onready var player = get_tree().get_first_node_in_group("Player")

enum STATES {IDLE, ATTACK, DEAD}
var currentState = STATES.IDLE

@export var attackRange = 2.0
@export var damage = 15
@export var attackSpeedModifier = 1.0

func _ready():
	var hitboxes = find_children("*", "HitBox")
	for hitbox in hitboxes:
		hitbox.onHurt.connect(statsManager.hurt)
	statsManager.died.connect(SetState.bind(STATES.DEAD))
	
	hitboxes.append(self)
	attackEmitter.SetBodiesToExclude(hitboxes)
	attackEmitter.SetDamage(damage)
	
	SetState(STATES.IDLE)
	
func hurt(damageData: DamageData):
	statsManager.hurt(damageData)
	
func SetState(state: STATES):
	if currentState == STATES.DEAD:
		return
	
	currentState = state
	match currentState:
		STATES.IDLE:
			animationPlayer.play("idle")
		STATES.ATTACK:
			# Enter ATTACK state immediately
			animationPlayer.play("walk", -1, 2.0) # optionally play approach animation
		STATES.DEAD:
			animationPlayer.play("die", 0.2)
			collision_layer = 0
			collision_mask = 1
			locomotionManager.StopMoving()

func _process(delta):
	match currentState:
		STATES.IDLE:
			ProcessIdleState(delta)
		STATES.ATTACK:
			ProcessAttackState(delta)

func ProcessIdleState(delta):
	if visionManager.CanSeeTarget(player):
		Alert()

func ProcessAttackState(_delta):
	var attacking = animationPlayer.current_animation == "attack"
	var vecToPlayer = player.global_position - global_position
	var dist = vecToPlayer.length()

	if dist > attackRange:
		locomotionManager.SetFacingDirection(vecToPlayer)
		locomotionManager.MoveToPoint(player.global_position)
		animationPlayer.play("walk", -1, 2.0)
	else:
		locomotionManager.StopMoving()
		if !attacking and visionManager.IsFacingTarget(player):
			StartAttack()
		elif !attacking:
			locomotionManager.SetFacingDirection(vecToPlayer)

func StartAttack():
	$AttackSound.play()
	animationPlayer.play("attack", -1, attackSpeedModifier)

func DoAttack(): # called from animation
	attackEmitter.Fire()

func Alert():
	if currentState == STATES.IDLE:
		$AlertSound.play()
		SetState(STATES.ATTACK)
		AlertNearbyMonster()

func AlertNearbyMonster():
	for b in nearbyMonstersAlertArea.get_overlapping_bodies():
		if b is Enemy:
			b.Alert()
