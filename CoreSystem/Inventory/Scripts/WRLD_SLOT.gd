extends Resource
class_name SlotData

const maxStackSize: int = 99

@export var item: Item
@export_range(1, maxStackSize) var quantity: int = 1: set = SetQuantity

func CanMergeWith(other_slot_data: SlotData) -> bool:
	return item == other_slot_data.item \
			and item.stackable \
			and quantity < maxStackSize

func CanFullyMergeWith(other_slot_data: SlotData) -> bool:
	return item == other_slot_data.item \
			and item.stackable \
			and quantity + other_slot_data.quantity <= maxStackSize

func FullyMergeWith(other_slot_data: SlotData) -> void:
	quantity += other_slot_data.quantity

func CreateSingleSlotData() -> SlotData:
	var new_slot_data = duplicate()
	new_slot_data.quantity = 1
	quantity -= 1
	return new_slot_data

func SetQuantity(value: int) -> void:
	quantity = value
	if quantity > 1 and not item.stackable:
		quantity = 1
		push_error("%s is not stackable, setting quantity to 1" % item.name)
