extends PanelContainer

const slot = preload("res://CoreSystem/Inventory/Prefabs/slot.tscn")

@export var itemGrid: GridContainer

func SetInventoryData(inventory_data: InventoryData) -> void:
		inventory_data.inventory_updated.connect(PopulateItemGrid)
		PopulateItemGrid(inventory_data)

func ClearInventoryData(inventory_data: InventoryData) -> void:
		inventory_data.inventory_updated.disconnect(PopulateItemGrid)

func PopulateItemGrid(inventory_data: InventoryData) -> void:
	for child in itemGrid.get_children():
		child.queue_free()
		
	for slot_data in inventory_data.slots_datas:
		var slot = slot.instantiate()
		itemGrid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.OnSlotClicked)
		
		if slot_data:
			slot.SetSlotData(slot_data)
