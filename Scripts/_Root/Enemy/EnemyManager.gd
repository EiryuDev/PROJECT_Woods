class_name Enemy extends CharacterBody3D

@onready var statsManager = $"Stats Manager"
@onready var visionManager = $"Vision Manager"

@onready var nearbyMonstersAlertArea = $NearbyMonstersAlertArea
@export var animationPlayer : AnimationPlayer

@onready var player = get_tree().get_first_node_in_group("Player")

enum STATES {IDLE, ATTACK, DEAD}
var currentState = STATES.IDLE

func _ready():
	var hitboxes = find_children("*", "HitBox")
	for hitbox in hitboxes:
		hitbox.onHurt.connect(statsManager.hurt)
	statsManager.died.connect(SetState.bind(STATES.DEAD))
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
		STATES.DEAD:
			animationPlayer.play("die", 0.2)
			collision_layer = 0
			collision_mask = 1

func _process(delta):
	match currentState:
		STATES.IDLE:
			ProcessIdleState(delta)
		STATES.ATTACK:
			ProcessAttackState(delta)

func ProcessIdleState(delta):
	if visionManager.CanSeeTarget(player):
		Alert()

func ProcessAttackState(delta):
	pass

func Alert():
	if currentState == STATES.IDLE:
		$AlertSound.play()
		SetState(STATES.ATTACK)
		AlertNearbyMonster()

func AlertNearbyMonster():
	for b in nearbyMonstersAlertArea.get_overlapping_bodies():
		if b is Enemy:
			b.Alert()
