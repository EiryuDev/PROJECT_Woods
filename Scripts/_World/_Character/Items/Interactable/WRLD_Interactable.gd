class_name Interactable
extends Area3D

@export var isCubeInteractable = false
@export var type : String = "Interact"

func action_use():
	if !isCubeInteractable:
		print("I am being interacted with")
	else:
		$MeshInstance3D.scale += Vector3(1,1,1)
