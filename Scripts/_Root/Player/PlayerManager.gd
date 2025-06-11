extends Node

@onready var playerStatsManager = $"Player Stats Manager"
@onready var playerLocomotionManager = $"Player Locomotion Manager"
@onready var playerWeaponManager = $"Camera3D/Player Weapon Manager"

const HOTKEYS = {
	KEY_1:0,
	KEY_2:1,
	KEY_3:2,
	KEY_4:3,
	KEY_5:4,
	KEY_6:5,
	KEY_7:6,
	KEY_8:7,
	KEY_9:8,
	KEY_0:9,
}
var isDead = false

func _ready():
	playerStatsManager.died.connect(kill)

func _process(delta):
	if isDead:
		return
		
	playerWeaponManager.Attack(Input.is_action_just_pressed("Attack"), Input.is_action_pressed("Attack"))
	pass

func _input(event):
	if isDead:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			playerWeaponManager.SwitchToPreviousWeapon()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			playerWeaponManager.SwitchToNextWeapon()
	
	if event is InputEventKey and event.pressed and event.keycode in HOTKEYS:
		playerWeaponManager.SwitchToWeaponSlot(HOTKEYS[event.keycode])
	

func Hurt(WRLD_DAMAGE_DATA: DamageData):
	playerStatsManager.hurt(WRLD_DAMAGE_DATA)

func kill():
	isDead = true;
	playerLocomotionManager.StopMovement()
