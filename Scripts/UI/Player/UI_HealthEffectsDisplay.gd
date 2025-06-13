extends Control

@onready var playerStatsManager = %"Player Stats Manager"

@onready var healed = $Healed
@onready var hurt = $Hurt
@onready var animationPlayer = $AnimationPlayer

func _ready():
	playerStatsManager.healed.connect(OnHeal)
	playerStatsManager.damaged.connect(OnHurt)
	pass

func OnHeal():
	animationPlayer.play("Flash")
	healed.show()
	hurt.hide()
	
func OnHurt():
	animationPlayer.play("Flash")
	hurt.show()
	healed.hide()
