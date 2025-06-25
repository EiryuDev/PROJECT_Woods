extends CharacterBody3D

@export var start_move_speed = 8
@export var grav = 35.0
@export var drag = 0.01
@export var velo_retained_on_bounce = 0.8

@onready var gib_graphics = $Graphics.get_children()
@onready var blood_particles = $BloodParticles

func _ready():
	for g in gib_graphics:
		g.hide()
	gib_graphics[randi_range(0, gib_graphics.size()-1)].show()
	randomize_rotation()
	velocity = -global_transform.basis.y * randf_range(0.0, start_move_speed)

func _physics_process(delta):
	velocity += -velocity * drag + Vector3.DOWN * grav * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var d = velocity
		var n = collision.get_normal()
		var r = d - 2 * d.dot(n) * n
		velocity = r * velo_retained_on_bounce
		var velo_magnitude = velocity.length()
		if velo_magnitude > 1.0:
			randomize_rotation()
		if velo_magnitude < 0.5:
			set_physics_process(false)

func randomize_rotation():
	rotation.x = randf_range(0.0, TAU)
	rotation.y = randf_range(0.0, TAU)
	rotation.z = randf_range(0.0, TAU)

func hurt(damage_data: DamageData):
	blood_particles.emitting = true
	$Graphics.hide()
	await get_tree().create_timer(0.5).timeout
	queue_free()
