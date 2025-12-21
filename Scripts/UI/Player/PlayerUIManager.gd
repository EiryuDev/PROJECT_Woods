extends Node

@export_group("Quest UI Settings")
@export var questPanel : Control
@export var questTitle : Label
@export var questDescription : Label

func _on_quit_game_pressed() -> void:
	get_tree().quit()
