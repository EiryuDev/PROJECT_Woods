extends Node

@onready var statsDisplay = $"../CanvasLayer/GUI/Stats Display"

# === Health Settings ===
@export var maxHealth = 100
@onready var currentHealth = maxHealth
@export var gibAt = -10
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
	currentHealth = 60
	currentStamina = maxStamina
	healthChanged.emit(currentHealth, maxHealth)
	staminaChanged.emit(currentStamina, maxStamina)
	if verbose:
		print("Starting health: %s/%s" % [currentHealth, maxHealth])
		print("Starting stamina: %s/%s" % [currentStamina, maxStamina])

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

func hurt(WRLD_DAMAGE_DATA: DamageData):
	if currentHealth <= 0:
		return
	currentHealth -= WRLD_DAMAGE_DATA.amount
	if currentHealth <= gibAt:
		gibbed.emit()
	if currentHealth <= 0:
		died.emit() 
	else:
		damaged.emit()
	healthChanged.emit(currentHealth, maxHealth)
	if verbose:
		print("Damaged for %s, health: %s/%s" % [WRLD_DAMAGE_DATA.amount, currentHealth, maxHealth])

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
	if verbose:
		print("Stamina used: %s, current stamina: %s/%s" % [amount, currentStamina, maxStamina])
