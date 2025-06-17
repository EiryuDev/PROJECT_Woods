extends Control

@onready var animationPlayer = $AnimationPlayer
@onready var restartButton = $Panel/RestartButton


func _ready():
	restartButton.button_up.connect(RestartLevel)
	hide()

func ShowDeathScreen():
	show()
	animationPlayer.play("fade_in")
	await animationPlayer.animation_finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func RestartLevel():
	get_tree().call_group("instanced", "queue_free")
	get_tree().reload_current_scene()
