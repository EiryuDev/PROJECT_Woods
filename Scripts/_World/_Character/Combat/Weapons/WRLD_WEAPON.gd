extends Node3D

class_name Weapon

@onready var animationPlayer : AnimationPlayer = $Graphics/AnimationPlayer
@onready var bulletEmitter = $BulletEmitter
@onready var firePoint : Node3D = %FirePoint
@onready var playerStatsManager = %"Player Stats Manager"

@export var automatic = false

@export var damage = 5
@export var ammo = 0
@export var staminaNeeded = 15

@export  var attackRate = 0.2
var lastAttackTime = -9999.9

@export var animationControlledAttack = false

@export var silentWeapon = false

signal fired
signal outOfAmmo
signal ammoUpdated(ammoAmount: int)

func _ready():
	bulletEmitter.SetDamage(damage)
	
func SetBodiesToExclude(bodies: Array):
	bulletEmitter.SetBodiesToExclude(bodies)
	
func Attack(inputJustPressed: bool, inputHeld: bool):
	if playerStatsManager.currentStamina < staminaNeeded:
		return
		
	if !automatic and !inputJustPressed:
		return
	if automatic and !inputHeld:
		return
		
	if ammo == 0:
		if inputJustPressed:
			outOfAmmo.emit()
			if has_node("OutofAmmoSound"):
				$OutofAmmoSound.play()
		return
	
	var curTime = Time.get_ticks_msec() / 1000.0
	if curTime - lastAttackTime < attackRate:
		return
		
	if ammo > 0:
		ammo -= 1
		
	if !animationControlledAttack:
		ActuallyAttack()
	lastAttackTime = curTime
	animationPlayer.stop()
	animationPlayer.play("Attack")
	if staminaNeeded > 0:
		playerStatsManager.hurtStamina(staminaNeeded)
	fired.emit()
	$AttackSounds.play()
	ammoUpdated.emit(ammo)
	if has_node("Graphics/MuzzleFlash"):
		$Graphics/MuzzleFlash.Flash()
	
func ActuallyAttack():
	bulletEmitter.global_transform = firePoint.global_transform
	bulletEmitter.Fire()
	
func set_active(a: bool):
	visible = a
	if !a:
		animationPlayer.play("RESET")
	else:
		$EquipSound.play()
		ammoUpdated.emit(ammo)

func isIdle() -> bool:
	return !animationPlayer.is_playing()
	
func AddAmmo(amount: int):
	ammo += amount
	ammoUpdated.emit(ammo)
