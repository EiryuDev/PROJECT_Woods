extends PanelContainer

@export var textureRect: TextureRect
@export var quantityLabel: Label 

signal slot_clicked(index: int, button: int)

func SetSlotData(slot_data: SlotData) -> void:
	var itemData = slot_data.item
	textureRect.texture = itemData.texture
	tooltip_text = "%s\n%s" % [itemData.name, itemData.itemLore]

	if slot_data.quantity > 1:
		quantityLabel.text = "x%s" % slot_data.quantity
		quantityLabel.show()
	else:
		quantityLabel.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
		
