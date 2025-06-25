extends Node3D

@onready var statsDisplay = $"../CanvasLayer/GUI/Stats Display"

const bloodHitEffect = preload("res://Resources/Prefabs/VFX Objects/Weapons/BloodHitEffect.tscn")
const BLOOD_DECAL = preload("res://Resources/Prefabs/VFX Objects/Weapons/BloodDecal.tscn")
const GIB = preload("res://Resources/Prefabs/VFX Objects/Weapons/Gib/Gib.tscn")

@onready var bloodRaycast = $BloodRaycast

# === Health Settings ===
@export var maxHealth = 100
@onready var currentHealth = maxHealth
@export var gibWhenDamageTaken = 20
var hasGibbed = false

@export var bloodSplatterCount = 3
@export var bloodSplatterRange = 2.0
@export var bloodSplatterSizeVariance = 0.5

@export var gibSpawnAmnt = 5

@export var verbose = true

# === Stamina Settings ===
@export var maxStamina = 100
@onready var currentStamina = maxStamina
@export var staminaRegenDelay = 1.5 # seconds before regen starts
@export var staminaRegenRate = 10.0 # per second

var _staminaRegenTimer: float = 0.0
var _isStaminaRegenerating := false

# === Signals ===
signal died
signal healed 
signal damaged
signal gibbed
signal healthChanged(currentHealth, maxHealth)
signal staminaChanged(currentStamina, maxStamina)

func _ready():
	currentStamina = maxStamina
	healthChanged.emit(currentHealth, maxHealth)
	staminaChanged.emit(currentStamina, maxStamina)
	if verbose:
		print("Starting health: %s/%s" % [currentHealth, maxHealth])
		#print("Starting stamina: %s/%s" % [currentStamina, maxStamina])

func _process(delta):
	if _isStaminaRegenerating:
		_staminaRegenTimer += delta
		if _staminaRegenTimer >= staminaRegenDelay:
			var regenAmount = staminaRegenRate * delta
			currentStamina = clamp(currentStamina + regenAmount, 0, maxStamina)
			staminaChanged.emit(currentStamina, maxStamina)
			if currentStamina >= maxStamina:
				_isStaminaRegenerating = false
				if verbose:
					print("Stamina fully regenerated.")

var damageTakenThisFrame = 0
var lastFrameDamaged = -1
func hurt(damageData: DamageData):
	SpawnBloodEffects(damageData)
	
	var currentFrame = Engine.get_process_frames()
	if lastFrameDamaged != currentFrame:
		damageTakenThisFrame = 0
	lastFrameDamaged = currentFrame
	damageTakenThisFrame += damageData.amount
	
	var dead = currentHealth <= 0
	if dead and damageTakenThisFrame >= gibWhenDamageTaken:
		Gib()
	
	if dead:
		return
	currentHealth -= damageData.amount
	dead = currentHealth <= 0
	
	if dead:
		if verbose:
			print("died")
		died.emit()
		if has_node("DieSound"):
			$DieSound.play()
		if damageTakenThisFrame >= gibWhenDamageTaken:
			Gib()
	else:
		if has_node("HurtSound"):
			$HurtSound.play()
		damaged.emit()
	healthChanged.emit(currentHealth, maxHealth)
	if verbose:
		print("damaged for %s, health: %s/%s" % [damageData.amount, currentHealth, maxHealth])

func Gib():
	if hasGibbed:
		return
	hasGibbed = true
	gibbed.emit()
	
	for _i in gibSpawnAmnt:
		var gib_inst = GIB.instantiate()
		get_tree().get_root().add_child(gib_inst)
		gib_inst.global_position = global_position
		gib_inst.add_to_group("instanced")
	
	if verbose:
		print("gibbed")

func heal(amount: int):
	if currentHealth <= 0:
		return
	currentHealth = clamp(currentHealth + amount, 0, maxHealth)
	healed.emit()
	healthChanged.emit(currentHealth, maxHealth)
	if verbose:
		print("Healed for %s, health: %s/%s" % [amount, currentHealth, maxHealth])

func hurtStamina(amount: float):
	currentStamina = clamp(currentStamina - amount, 0, maxStamina)
	staminaChanged.emit(currentStamina, maxStamina)
	_staminaRegenTimer = 0.0
	_isStaminaRegenerating = true
	#if verbose:
		#print("Stamina used: %s, current stamina: %s/%s" % [amount, currentStamina, maxStamina])

func SpawnBloodEffects(damageData: DamageData):
	var bloodHitEffect = bloodHitEffect.instantiate()
	get_tree().get_root().add_child(bloodHitEffect)
	bloodHitEffect.global_position = damageData.hitPos
	
	bloodRaycast.enabled = true
	for _i in bloodSplatterCount:
		var h_angle = randf_range(0.0, PI / 2.0)
		var v_angle = randf_range(0.0, TAU)
		var dir = Vector3.DOWN.rotated(Vector3.RIGHT, h_angle)
		dir = dir.rotated(Vector3.UP, v_angle)
		var raycastTo = global_position + dir * bloodSplatterRange
		bloodRaycast.target_position = bloodRaycast.to_local(raycastTo)
		bloodRaycast.force_raycast_update()
		if !bloodRaycast.is_colliding():
			continue
		
		var hitPos = bloodRaycast.get_collision_point()
		var hit_normal = bloodRaycast.get_collision_normal()
		var blood_decal = BLOOD_DECAL.instantiate()
		get_tree().get_root().add_child(blood_decal)
		blood_decal.global_position = hitPos
		blood_decal.add_to_group("instanced")
		var look_at_pos = hitPos + hit_normal
		if hit_normal.is_equal_approx(Vector3.UP) or hit_normal.is_equal_approx(Vector3.DOWN):
			blood_decal.look_at(look_at_pos, Vector3.RIGHT)
		else:
			blood_decal.look_at(look_at_pos)
		
		blood_decal.rotate_object_local(Vector3.FORWARD, randf_range(0.0, TAU))
		blood_decal.scale *= 1.0 + randf_range(-bloodSplatterSizeVariance, bloodSplatterSizeVariance)
		
	bloodRaycast.enabled = false
