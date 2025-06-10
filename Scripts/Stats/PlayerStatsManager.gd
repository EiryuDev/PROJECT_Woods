extends Node

@export var maxHealth = 100
@onready var currentHealth = maxHealth
@export var gibAt = -10
@export var verbose = false

signal died
signal healed 
signal damaged
signal gibbed
signal healthChanged(currentHealth, maxHealth)

func _ready():
	healthChanged.emit(currentHealth, maxHealth)
	if verbose:
		print("Starting health: %s/%s" % [currentHealth, maxHealth])

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
