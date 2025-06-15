extends Control

@onready var playerStatsManager = %"Player Stats Manager"
@onready var playerWeaponManager = %"Player Weapon Manager"

@onready var ammoDisplay = $"Ammo Display"
@onready var healthDisplay = $"Health Display"
@onready var staminaDisplay = $"Stamina Display"

func _ready():
	playerStatsManager.healthChanged.connect(UpdateHealthDisplay)
	playerStatsManager.staminaChanged.connect(UpdateStaminaDisplay) # New: connect stamina signal

	for weapon in playerWeaponManager.weapons:
		weapon.ammoUpdated.connect(UpdateAmmoDisplay)

	UpdateHealthDisplay(playerStatsManager.currentHealth, playerStatsManager.maxHealth)
	UpdateStaminaDisplay(playerStatsManager.currentStamina, playerStatsManager.maxStamina) # New: set initial stamina display
	UpdateAmmoDisplay(playerWeaponManager.currentWeapon.ammo)

func UpdateHealthDisplay(currentHealth: int, maxHealth: int):
	healthDisplay.max_value = maxHealth
	healthDisplay.value = currentHealth

func UpdateAmmoDisplay(ammoAmount: int):
	if ammoAmount < 0:
		ammoDisplay.text = "Ammo: inf"
	else:
		ammoDisplay.text = "Ammo: %s" % ammoAmount

func UpdateStaminaDisplay(currentStamina: float, maxStamina: float): # New: stamina display update function
	staminaDisplay.max_value = maxStamina
	staminaDisplay.value = currentStamina
