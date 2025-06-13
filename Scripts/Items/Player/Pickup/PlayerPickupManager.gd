extends Area3D

@onready var playerStatsManager = %"Player Stats Manager"
@onready var playerWeaponManager = %"Player Weapon Manager"

func _ready():
	area_entered.connect(OnAreaEnter)
	
func OnAreaEnter(pickup: Area3D):
	var deleteOnPickup = true
	if pickup is Pickup:
		match pickup.pickupType:
			Pickup.PICKUP_TYPES.HEALTH:
				if playerStatsManager.currentHealth < playerStatsManager.maxHealth:
					playerStatsManager.heal(pickup.pickupAmount)
				else:
					deleteOnPickup = false
			Pickup.PICKUP_TYPES.WEAPON:
				var weapon : Weapon = playerWeaponManager.GetWeaponFromPickUpType(pickup.weaponType)
				playerWeaponManager.UnlockWeapon(weapon)
				weapon.AddAmmo(pickup.pickupAmount)
			Pickup.PICKUP_TYPES.AMMO:
				var weapon : Weapon = playerWeaponManager.GetWeaponFromPickUpType(pickup.weaponType)
				weapon.AddAmmo(pickup.pickupAmount)
	
	if deleteOnPickup:
		pickup.Pickup()
