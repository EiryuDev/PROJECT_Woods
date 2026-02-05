extends Interactable

@export var slot_data: SlotData
	
func action_use(wants_grab := false):
	if player.playerInventoryManager.inventoryData.PickUpSlotData(slot_data):
		queue_free()
