extends Control

signal drop_slot_data(slot_data: SlotData)

var grabbedSlotData: SlotData
var external_inventory_owner 

@export var playerInventory: PanelContainer
@export var externalInventory: PanelContainer
@export var grabbed_slot: PanelContainer

func _physics_process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)

func SetPlayerInventoryData(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(OnInventoryInteract)
	playerInventory.SetInventoryData(inventory_data)

func OnInventoryInteract(inventory_data: InventoryData, index: int, button: int) -> void:
	match [grabbedSlotData, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbedSlotData = inventory_data.GrabSlotData(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbedSlotData = inventory_data.DropSlotData(grabbedSlotData, index)
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbedSlotData = inventory_data.DropSingleSlotData(grabbedSlotData, index)

		
	UpdateGrabbedSlot()

func UpdateGrabbedSlot() -> void:
	if grabbedSlotData:
		grabbed_slot.show()
		grabbed_slot.SetSlotData(grabbedSlotData)
	else:
		grabbed_slot.hide()

func SetExternalInventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data

	inventory_data.inventory_interact.connect(OnInventoryInteract)
	externalInventory.SetInventoryData(inventory_data)
	
	externalInventory.show()

func ClearExternalInventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data

		inventory_data.inventory_interact.disconnect(OnInventoryInteract)
		externalInventory.ClearInventoryData(inventory_data)
		
		externalInventory.hide()
		external_inventory_owner = null


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbedSlotData:
				
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbedSlotData)
				grabbedSlotData = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbedSlotData.CreateSingleSlotData())
				if grabbedSlotData.quantity < 1:
					grabbedSlotData = null
				
		UpdateGrabbedSlot()


func _on_visibility_changed() -> void:
	if not visible and grabbedSlotData:
		drop_slot_data.emit(grabbedSlotData)
		grabbedSlotData = null
		UpdateGrabbedSlot()
