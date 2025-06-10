extends Node

@onready var playerStatsManager = $"Player Stats Manager"
@onready var playerLocomotionManager = $"Player Locomotion Manager"

var isDead = false

func _ready():
	playerStatsManager.died.connect(kill)
	
func kill():
	isDead = true;
	playerLocomotionManager.StopMovement()
