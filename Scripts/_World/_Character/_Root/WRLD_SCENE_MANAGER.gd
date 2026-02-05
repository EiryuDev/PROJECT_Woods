extends Node3D

@onready var terrain = $Node3D/Terrain3D  # change to match your node path
@onready var player: CharacterBody3D = $Player

func _ready():
	await get_tree().process_frame  # Give the engine 1 frame to initialize

	if terrain:
		print("Refreshing terrain visibility")
		terrain.visible = false
		await get_tree().process_frame
		terrain.visible = true
		
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(player.playerInventoryManager.ToggleInventoryInterface)
		
