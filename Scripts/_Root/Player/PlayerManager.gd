class_name PlayerManager
extends Node

@onready var playerStatsManager = %"Player Stats Manager"
@onready var playerLocomotionManager = $"Player Locomotion Manager"
@onready var playerWeaponManager = $"Camera3D/Player Weapon Manager"
@export var playerUIManager : CanvasLayer
@export var playerInventoryManager : Node3D
@onready var interactRaycast = $Camera3D/InteractRayCast
@onready var interactDisplay =  $"Player UI Manager/GUI/Interact Display"
@onready var deathScreen = $"Player UI Manager/GUI/DeathScreen"
@onready var canvasLayer = $"Player UI Manager"
@onready var objectPoint = %ObjectPoint

@export_group("FLAGS")
@export var canMove = true

@export_group("INTERACTION DATA")
@export var camera: Camera3D
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
var toggleHideUI = false
var togglePause = false

signal toggleInventory()

func _ready():
	playerStatsManager.died.connect(kill)
	print(pickupPoint.name)
	add_to_group("player")

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

func is_holding_item() -> bool:
	return pickupPoint.get_child_count() > 0
	
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
		if interacted == null:
			return
		if !interacted.is_in_group("Interactable"):
			return
		if !interacted.has_method("action_use"):
			return
		# 🚫 If holding something, block interaction
		if is_holding_item():
			return
		# Interact ONLY
		interacted.action_use(false)
		
	if Input.is_action_just_pressed("Grab"):
		var interacted = interactRaycast.get_collider()
		if interacted == null:
			return
		if !interacted.is_in_group("Interactable"):
			return
		# Only grab-capable items
		if is_holding_item():
			return
		interacted.action_use(true)

	
	if Input.is_action_just_pressed("hide ui"):
		if !toggleHideUI:
			toggleHideUI = true
			playerStatsManager.statsDisplay.visible = false
		else:
			toggleHideUI = false
			playerStatsManager.statsDisplay.visible = true
	
	if Input.is_action_just_pressed("pause"):
		if !togglePause:
			togglePause = true
			$"Player UI Manager/GUI/Pause Display".visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			togglePause = false
			$"CanvasLayer/GUI/Pause Display".visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Inventory"):
		toggleInventory.emit()
		
func hurt(WRLD_DAMAGE_DATA: DamageData):
	playerStatsManager.hurt(WRLD_DAMAGE_DATA)

func kill():
	isDead = true;
	playerLocomotionManager.StopMovement()
	deathScreen.ShowDeathScreen()
