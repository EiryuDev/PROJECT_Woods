extends Area3D

@onready var playerStatsManager = %"Player Stats Manager"
@onready var playerWeaponManager = %"Player Weapon Manager"
@onready var pickupInfoDisplay = %"Pickup Info Display"

@onready var ammo_sounds = {
	Pickup.WEAPONS.DEAGLE: $PickUpDeagleAmmo
}

func _ready():
	area_entered.connect(OnAreaEnter)
	
func OnAreaEnter(pickup: Area3D):
	var deleteOnPickup = true
	if pickup is Pickup:
		match pickup.pickupType:
			Pickup.PICKUP_TYPES.HEALTH:
				if playerStatsManager.currentHealth < playerStatsManager.maxHealth:
					playerStatsManager.heal(pickup.pickupAmount)
					$PickUpHealth.play()
				else:
					deleteOnPickup = false
			Pickup.PICKUP_TYPES.WEAPON:
				var weapon : Weapon = playerWeaponManager.GetWeaponFromPickUpType(pickup.weaponType)
				playerWeaponManager.UnlockWeapon(weapon)
				weapon.AddAmmo(pickup.pickupAmount)
				ammo_sounds[pickup.weaponType].play()
			Pickup.PICKUP_TYPES.AMMO:
				var weapon : Weapon = playerWeaponManager.GetWeaponFromPickUpType(pickup.weaponType)
				weapon.AddAmmo(pickup.pickupAmount)
				ammo_sounds[pickup.weaponType].play()
	
	if deleteOnPickup:
		pickupInfoDisplay.OnPickup(pickup)
		pickup.Pickup()
