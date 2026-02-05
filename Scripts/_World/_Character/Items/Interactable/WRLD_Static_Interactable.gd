extends StaticBody3D

enum INTERACTABLE_TYPES {HANDPUMP}
@export var interactableType = INTERACTABLE_TYPES.HANDPUMP
@export var type : String = "Interact"

@onready var player : PlayerManager
@onready var collisionShape = $CollisionShape3D

func _ready():
	player = get_node("../Player")
	
func action_use(wants_grab := false):
	match interactableType:
		INTERACTABLE_TYPES.HANDPUMP:
			$"../AnimationPlayer".play("Pump")
			$"../WaterLeak".start_water_effect()
