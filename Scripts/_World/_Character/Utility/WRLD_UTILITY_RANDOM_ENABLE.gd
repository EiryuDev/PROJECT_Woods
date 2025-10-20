extends Node3D

@export_group("ENABLE DATA")
@export var enableChance := 0.5
@export var objectToEnable : Node3D


func _ready():
	randomize()
	
	var shouldEnable := randf() < enableChance
	objectToEnable.visible = shouldEnable
