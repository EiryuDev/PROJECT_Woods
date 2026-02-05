extends Node3D

const PickUp = preload("res://CoreSystem/Items/Apple/Prefab/Apple.tscn")

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


func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = GetDropPosition()
	get_tree().current_scene.add_child(pick_up)

func GetDropPosition() -> Vector3:
	var direction = -player.camera.global_transform.basis.z
	return player.camera.global_position + (direction * 2)
