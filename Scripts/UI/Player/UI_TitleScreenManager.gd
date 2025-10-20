extends CanvasLayer

@onready var mainMenuCamera = $"../Main Menu Camera"
@export var bgmVolumeName: String
@export var sfxVolumeName: String

var masterBusID
var bgmBusID
var sfxBusID

func _ready():
	$"Main Menu/Menu Options/VBoxContainer/Play Button".grab_focus()
	masterBusID = AudioServer.get_bus_index("Master")
	bgmBusID = AudioServer.get_bus_index(bgmVolumeName)
	sfxBusID = AudioServer.get_bus_index(sfxVolumeName)
	
	var video_settings = ConfigFileManager.load_video_settings()
	%"Fullscreen CheckBox".button_pressed = video_settings.fullscreen
	
	var audio_settings = ConfigFileManager.load_audio_settings()
	%"Master Volume".value = min(audio_settings.master_volume, 1.0) * 100
	%"BGM Volume".value = min(audio_settings.bgm_volume, 1.0) * 100
	%"SFX Volume".value = min(audio_settings.sfx_volume, 1.0) * 100
	
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
	$"Main Menu/Menu Options/VBoxContainer/Options Button".grab_focus()
	mainMenuCamera.parallaxEffect = true
	$"Main Menu/Settings Options".visible = false
	
func OpenCreditsMenu():
	mainMenuCamera.parallaxEffect = false
	$"Main Menu/Credits Options".visible = true
	
func CloseCreditsMenu():
	$"Main Menu/Menu Options/VBoxContainer/Credits Button".grab_focus()
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
	ConfigFileManager.save_video_setting("fullscreen", toggled_on)
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func OnVSyncToggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func SetGraphicsQuality(index: int) -> void:
	match index:
		0:  # Low
			ProjectSettings.set_setting("rendering/quality/driver/driver_name", "forward_plus")
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 0)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
			ProjectSettings.set_setting("rendering/quality/shadows/atlas_size", 1024)
			ProjectSettings.set_setting("rendering/quality/shadows/directional_shadow_max_distance", 50.0)
			ProjectSettings.set_setting("rendering/quality/ssao/quality", 0)
			ProjectSettings.set_setting("rendering/quality/screen_space_reflection/quality", 0)
			ProjectSettings.set_setting("rendering/quality/sdfgi/frames_to_converge", 16)
			ProjectSettings.set_setting("rendering/textures/default_filters/mipmap_bias", 1.5)  # Blurrier/lower res
			
		1:  # Medium
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 2)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
			ProjectSettings.set_setting("rendering/quality/shadows/atlas_size", 2048)
			ProjectSettings.set_setting("rendering/quality/shadows/directional_shadow_max_distance", 150.0)
			ProjectSettings.set_setting("rendering/quality/ssao/quality", 1)
			ProjectSettings.set_setting("rendering/quality/screen_space_reflection/quality", 1)
			ProjectSettings.set_setting("rendering/quality/sdfgi/frames_to_converge", 8)
			ProjectSettings.set_setting("rendering/textures/default_filters/mipmap_bias", 0.5)
			
		2:  # High
			ProjectSettings.set_setting("rendering/quality/filters/msaa", 4)
			ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 2)
			ProjectSettings.set_setting("rendering/quality/shadows/atlas_size", 4096)
			ProjectSettings.set_setting("rendering/quality/shadows/directional_shadow_max_distance", 300.0)
			ProjectSettings.set_setting("rendering/quality/ssao/quality", 2)
			ProjectSettings.set_setting("rendering/quality/screen_space_reflection/quality", 2)
			ProjectSettings.set_setting("rendering/quality/sdfgi/frames_to_converge", 4)
			ProjectSettings.set_setting("rendering/textures/default_filters/mipmap_bias", 0.0)

	print("Graphics quality set to index:", index)

func PlayButtonHoverSound() -> void:
	$"Main Menu/Button Hover".play()

func PlayButtonPressedSound() -> void:
	$"Main Menu/Button Pressed".play()


func _on_master_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileManager.save_audio_settings("master_volume", %"Master Volume".value / 100)

func _on_bgm_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileManager.save_audio_settings("bgm_volume", %"BGM Volume".value / 100)

func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileManager.save_audio_settings("sfx_volume", %"SFX Volume".value / 100)

func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
