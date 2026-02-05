extends Node3D

@export var player: CharacterBody3D
@export var inventoryData: InventoryData
@export var inventoryInterface: Control

func _ready() -> void:
	player.toggleInventory.connect(ToggleInventoryInterface)
	inventoryInterface.SetPlayerInventoryData(inventoryData)

func ToggleInventoryInterface(external_inventory_owner = null) -> void:
	inventoryInterface.visible = not inventoryInterface.visible
	
	if inventoryInterface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if external_inventory_owner and inventoryInterface.visible:
		inventoryInterface.SetExternalInventory(external_inventory_owner) 
	else:
		inventoryInterface.ClearExternalInventory()
