extends Node3D

@onready var animationPlayer = $AnimationPlayer
@onready var weapons = $Weapons.get_children()
var weaponsUnlocked = []
var currentSlot = 0
var currentWeapon = null

@onready var crosshair = $"../../GUI/Crosshair"

func _ready():
	for weapon in weapons:
		if weapon.has_method("SetBodiesToExclude"):
			weapon.SetBodiesToExclude([get_parent().get_parent()])
	DisableAllWeapons()
	for _i in range(weapons.size()):
		weaponsUnlocked.append(false) # True for testing, default false
	weaponsUnlocked[0] = true
	SwitchToWeaponSlot(0)
	
func _process(delta):
	if currentSlot == 0:
		crosshair.visible = false
	else:
		crosshair.visible = true
		
func Attack(inputJustPressed: bool, inputHeld: bool):
	if currentWeapon is Weapon:
		currentWeapon.Attack(inputJustPressed, inputHeld)
	
func UnlockWeapon(weapon : Weapon):
	if weapon == null:
		return
	var weaponIndex = weapon.get_index()
	var weaponAlreadyUnlocked = weaponsUnlocked[weaponIndex]
	weaponsUnlocked[weaponIndex] = true
	if !weaponAlreadyUnlocked:
		SwitchToWeaponSlot(weaponIndex)
	
func DisableAllWeapons():
	for weapon in weapons:
		if has_method("set_active"):
			weapon.set_active(false)
		else:
			weapon.hide()

func SwitchToPreviousWeapon():
	for i in range(weapons.size()):
		var wrappedIndex = wrapi(currentSlot - 1 - i, 0, weapons.size())
		if SwitchToWeaponSlot(wrappedIndex):
			break
	
func SwitchToNextWeapon():
	for i in range(weapons.size()):
		var wrappedIndex = wrapi(currentSlot + 1 + i, 0, weapons.size())
		if SwitchToWeaponSlot(wrappedIndex):
			break

func SwitchToWeaponSlot(slotIndex: int)->bool:
	if slotIndex >= weapons.size() or slotIndex < 0:
		return false
	if weaponsUnlocked.size() == 0 or !weaponsUnlocked[slotIndex]:
		return false
		
	DisableAllWeapons()
	currentSlot = slotIndex
	currentWeapon = weapons[currentSlot]
	if has_method("set_active"):
		currentWeapon.set_active(true)
	else:
		currentWeapon.show()
		
	return true

func UpdateAnimation(velocity: Vector3, grounded: bool):
	if currentWeapon is Weapon and !currentWeapon.isIdle():
		animationPlayer.play("RESET")
	elif !grounded or velocity.length() < 3.0:
		animationPlayer.play("RESET", 0.3)
	else:
		animationPlayer.play("Moving", 0.3)

func GetWeaponFromPickUpType(weaponType: Pickup.WEAPONS) -> Weapon:
	match weaponType:
		Pickup.WEAPONS.DEAGLE:
			return $"Weapons/Desert Eagle"
	return null
