extends Node3D

@onready var weapons = $Weapons.get_children()
var weaponsUnlocked = []
var currentSlot = 0
var currentWeapon = null

@onready var crosshair = $"../../GUI/Crosshair"

func _ready():
	DisableAllWeapons()
	for _i in range(weapons.size()):
		weaponsUnlocked.append(true) # True for testing, default false
	pass
	
func _process(delta):
	if currentSlot == 0:
		crosshair.visible = false
	else:
		crosshair.visible = true
		
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
