extends CanvasLayer

@onready var mainMenuCamera = $"../Main Menu Camera"
@export var bgmVolumeName: String
@export var sfxVolumeName: String

var masterBusID
var bgmBusID
var sfxBusID

func _ready():
	masterBusID = AudioServer.get_bus_index("Master")
	bgmBusID = AudioServer.get_bus_index(bgmVolumeName)
	sfxBusID = AudioServer.get_bus_index(sfxVolumeName)
	
func PlayGame():
	call_deferred("_load_game_scene")

func _load_game_scene():
	var scene_path = "res://Scenes/Level/Scene_BikeScene01.tscn"
	var scene = load(scene_path)
	get_tree().change_scene_to_packed(scene)
	
func QuitGame():
	get_tree().quit()

func OpenSettingsMenu():
	mainMenuCamera.parallaxEffect = false
	$"Main Menu/Settings Options".visible = true
	
func CloseSettingsMenu():
	mainMenuCamera.parallaxEffect = true
	$"Main Menu/Settings Options".visible = false
	
func OpenCreditsMenu():
	mainMenuCamera.parallaxEffect = false
	$"Main Menu/Credits Options".visible = true
	
func CloseCreditsMenu():
	mainMenuCamera.parallaxEffect = true
	$"Main Menu/Credits Options".visible = false

func OnMasterVolumeValueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(masterBusID, value)
	
func OnBGMVolumeValueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(bgmBusID, value)

func OnSFXVolumeValueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(sfxBusID, value)
	
func OnMuteToggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)

func OnResolutionsItemSelected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))

func OnFullscreenToggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
