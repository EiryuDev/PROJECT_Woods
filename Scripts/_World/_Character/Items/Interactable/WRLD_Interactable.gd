class_name Interactable
extends RigidBody3D

@export var isCubeInteractable = false
enum INTERACTABLE_TYPES {GENERIC, CUBE1, PICKABLE, CHEST}
@export var interactableType = INTERACTABLE_TYPES.GENERIC
@export var type : String = "Interact"

@onready var player : PlayerManager
@onready var collisionShape = $CollisionShape3D

@export var inventory_data: InventoryData
signal toggle_inventory(external_inventory_owner)

func _ready():
	player = get_node("../Player")

func action_use(wants_grab := false):
	match interactableType:
		INTERACTABLE_TYPES.GENERIC:
			print("I am being interacted with")
			pass
		INTERACTABLE_TYPES.CUBE1:
			$MeshInstance3D.scale += Vector3(1,1,1)
			pass
		INTERACTABLE_TYPES.PICKABLE:
			if wants_grab:
				PickUpTheItem()
		INTERACTABLE_TYPES.CHEST:
			if wants_grab:
				PickUpTheItem()
			else:
				toggle_inventory.emit(self)
			
			pass

func reset_pickup_state():
	freeze = false
	collisionShape.disabled = false
	gravity_scale = 1

func PickUpTheItem() -> void:
	# Prevent picking up if already holding something
	if player.pickupPoint.get_child_count() > 0:
		return

	var oldParent = get_parent()
	oldParent.remove_child(self)

	# Reparent under the camera's PickupPoint
	player.pickupPoint.add_child(self)

	# Reset local transform
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	scale = scale  # Optional: keeps scale intact

	# Adjust physics properties
	gravity_scale = 0
	collisionShape.disabled = true
	freeze = true  # OR mode = RigidBody3D.MODE_STATIC

	# Delay before allowing throw
	await get_tree().create_timer(1.0).timeout
	if player.pickupPoint.has_method("enable_throw"):
		player.pickupPoint.enable_throw()
