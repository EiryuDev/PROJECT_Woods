extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		# --- Default Keybindings ---
		config.set_value("keybinding", "move_forward", "W")
		config.set_value("keybinding", "move_backward", "S")
		config.set_value("keybinding", "move_left", "A")
		config.set_value("keybinding", "move_right", "D")
		
		# --- Default Video Settings ---
		config.set_value("video", "fullscreen", true)
		
		# --- Default Audio Settings ---
		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "bgm_volume", 1.0)
		config.set_value("audio", "sfx_volume", 1.0)
		
		# --- Default Player Transform ---
		config.set_value("player", "x", 0.0)
		config.set_value("player", "y", 0.0)
		config.set_value("player", "z", 0.0)
		config.set_value("player", "rot_x", 0.0)
		config.set_value("player", "rot_y", 0.0)
		config.set_value("player", "rot_z", 0.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


# =======================
#  VIDEO SETTINGS
# =======================
func save_video_setting(key: String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)
	
	
func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings


# =======================
#  AUDIO SETTINGS
# =======================
func save_audio_settings(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)
	
func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings


# =======================
#  PLAYER TRANSFORM
# =======================
func save_player_position(player: Node3D):
	config.set_value("player", "x", player.global_position.x)
	config.set_value("player", "y", player.global_position.y)
	config.set_value("player", "z", player.global_position.z)
	
	config.set_value("player", "rot_x", player.rotation.x)
	config.set_value("player", "rot_y", player.rotation.y)
	config.set_value("player", "rot_z", player.rotation.z)
	
	config.save(SETTINGS_FILE_PATH)


func load_player_position() -> Dictionary:
	if config.has_section("player"):
		var pos = Vector3(
			config.get_value("player", "x", 0.0),
			config.get_value("player", "y", 0.0),
			config.get_value("player", "z", 0.0)
		)
		
		var rot = Vector3(
			config.get_value("player", "rot_x", 0.0),
			config.get_value("player", "rot_y", 0.0),
			config.get_value("player", "rot_z", 0.0)
		)
		
		return {
			"position": pos,
			"rotation": rot
		}
	
	return {
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO
	}
