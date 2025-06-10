extends Node

func _ready():
	DiscordRPC.app_id = 1381584835017179257
	DiscordRPC.state = "Making this in Godot"
	DiscordRPC.details = "Exploring the woods"
	
	DiscordRPC.refresh()
	
	
