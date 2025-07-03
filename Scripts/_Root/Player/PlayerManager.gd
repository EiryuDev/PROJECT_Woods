class_name PlayerManager
extends Node

@onready var playerStatsManager = %"Player Stats Manager"
@onready var playerLocomotionManager = $"Player Locomotion Manager"
@onready var playerWeaponManager = $"Camera3D/Player Weapon Manager"
@onready var interactRaycast = $Camera3D/InteractRayCast
@onready var interactDisplay =  $"CanvasLayer/GUI/Interact Display"
@onready var deathScreen = $CanvasLayer/GUI/DeathScreen
@onready var canvasLayer = $CanvasLayer
@onready var objectPoint = %ObjectPoint

@export_group("FLAGS")
@export var canMove = true

@export_group("INTERACTION DATA")
@onready var pickupPoint = $Camera3D/PickupPoint

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
var toggleActive = false

func _ready():
	playerStatsManager.died.connect(kill)
	print(pickupPoint.name)

func _process(delta):
	if isDead:
		return
		
	playerWeaponManager.Attack(Input.is_action_just_pressed("Attack"), Input.is_action_pressed("Attack"))
	PromptInteractable()

func PromptInteractable():
	if interactRaycast.is_colliding():
		if is_instance_valid(interactRaycast.get_collider()):
			if interactRaycast.get_collider().is_in_group("Interactable"):
				interactDisplay.text = interactRaycast.get_collider().type
				interactDisplay.visible = true
			else:
				interactDisplay.visible = false
	else:
		interactDisplay.visible = false

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
	
	if Input.is_action_just_pressed("interact"):
		var interacted = interactRaycast.get_collider()
		if interacted != null and interacted.is_in_group("Interactable") and interacted.has_method("action_use"):
			interacted.action_use()
	
	if Input.is_action_just_pressed("hide ui"):
		if !toggleActive:
			toggleActive = true
			playerStatsManager.statsDisplay.visible = false
		else:
			toggleActive = false
			playerStatsManager.statsDisplay.visible = true
		

func hurt(WRLD_DAMAGE_DATA: DamageData):
	playerStatsManager.hurt(WRLD_DAMAGE_DATA)

func kill():
	isDead = true;
	playerLocomotionManager.StopMovement()
	deathScreen.ShowDeathScreen()
