extends CanvasLayer

@onready var mainMenuCamera = $"../Main Menu Camera"

func PlayGame():
	call_deferred("_load_game_scene")

func _load_game_scene():
	var scene_path = "res://Scenes/Level/Scene_BikeScene01.tscn"
	var scene = load(scene_path)
	get_tree().change_scene_to_packed(scene)

	
func QuitGame():
	get_tree().quit()

func OpenCreditsMenu():
	mainMenuCamera.parallaxEffect = false
	$"Main Menu/Credits Options".visible = true
	
func CloseCreditsMenu():
	mainMenuCamera.parallaxEffect = true
	$"Main Menu/Credits Options".visible = false
