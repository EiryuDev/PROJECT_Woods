extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)

@export var slots_datas: Array[SlotData] 

func OnSlotClicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)

func GrabSlotData(index: int) -> SlotData:
	var slot_data = slots_datas[index]
	
	if slot_data:
		slots_datas[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

func DropSlotData(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slots_datas[index]
	
	var return_slot_data: SlotData
	if slot_data and slot_data.CanFullyMergeWith(grabbed_slot_data):
		slot_data.FullyMergeWith(grabbed_slot_data)
	else:
		slots_datas[index] = grabbed_slot_data
		return_slot_data = slot_data
		
	inventory_updated.emit(self)
	return return_slot_data
	
func DropSingleSlotData(grabbed_slot_data: SlotData, index: int) -> SlotData:
	var slot_data = slots_datas[index]
	
	if not slot_data:
		slots_datas[index] = grabbed_slot_data.CreateSingleSlotData()
	elif slot_data.CanMergeWith(grabbed_slot_data):
		slot_data.FullyMergeWith(grabbed_slot_data.CreateSingleSlotData())
		
	inventory_updated.emit(self)
	
	if grabbed_slot_data.quantity > 0:
		return grabbed_slot_data
	else:
		return null

func PickUpSlotData(slot_data: SlotData) -> bool:
	for index in slots_datas.size():
		if not slots_datas[index]:
			slots_datas[index] = slot_data
			inventory_updated.emit(self)
			return true
	
	return false
