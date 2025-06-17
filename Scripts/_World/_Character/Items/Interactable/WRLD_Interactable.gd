class_name Interactable
extends RigidBody3D

@export var isCubeInteractable = false
enum INTERACTABLE_TYPES {GENERIC, CUBE1, CUBE2}
@export var interactableType = INTERACTABLE_TYPES.GENERIC
@export var type : String = "Interact"

func action_use():
	match interactableType:
		INTERACTABLE_TYPES.GENERIC:
			print("I am being interacted with")
			pass
		INTERACTABLE_TYPES.CUBE1:
			$MeshInstance3D.scale += Vector3(1,1,1)
			pass
		INTERACTABLE_TYPES.CUBE2:
			#Inspect code here
			pass
		
