extends Node3D

@export var startTime = 6
@export var dayLengthInSecond:int = 24*5

@export var morningColorTop: Color = Color("5897fa")
@export var morningColorHorizon: Color = Color("d3916b")

@export var dayColorTop: Color = Color("1f6ddf")
@export var dayColorHorizon: Color = Color("56a9f5")

@export var afternoonColorTop: Color = Color("3d6fcd")
@export var afternoonColorHorizon: Color = Color("e98174")

@export var nightColorTop: Color = Color("090e14")
@export var nightColorHorizon: Color = Color("010049")

# --- FOG PRESETS ---
@export var dayFogColor: Color = Color("d7ffcf")     # screenshot-like light green
@export var eveningFogColor: Color = Color("e89b5a") # warm orange
@export var nightFogColor: Color = Color.BLACK

@export var dayFogDensity := 0.03
@export var eveningFogDensity := 0.02
@export var nightFogDensity := 0.0
	
@onready var worldEnvironment: WorldEnvironment = $WorldEnvironment
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var env := worldEnvironment.environment

var dayDuration = 24
var dayColorList = [
	{
		"top": morningColorTop,
		"horizon": morningColorHorizon,
		"startTime": 6,
		"fog_color": dayFogColor,
		"fog_density": dayFogDensity
	},
	{
		"top": dayColorTop,
		"horizon": dayColorHorizon,
		"startTime": 8,
		"fog_color": dayFogColor,
		"fog_density": dayFogDensity
	},
	{
		"top": afternoonColorTop,
		"horizon": afternoonColorHorizon,
		"startTime": 18,
		"fog_color": eveningFogColor,
		"fog_density": eveningFogDensity
	},
	{
		"top": nightColorTop,
		"horizon": nightColorHorizon,
		"startTime": 20,
		"fog_color": nightFogColor,
		"fog_density": nightFogDensity
	}
]


var currentDayState = 0
var durationMultiplier = 1

func _ready() -> void:
	ChangeDuration()
	
	SetSun()
	
	SetCurrentState()
	
	RefreshDayState()
	
	DayAnimationChange()
	
func ChangeDuration():
	durationMultiplier = dayLengthInSecond/24
	animationPlayer.speed_scale= 1.0 / durationMultiplier
	
func SetSun():
	animationPlayer.play("Day&NightCycle")
	animationPlayer.seek(startTime)
	
func SetCurrentState():
	for i in dayColorList.size():
		if startTime < dayColorList[i].startTime:
			currentDayState = i - 1
			return

func RefreshDayState():
	var newState = false

	for i in dayColorList.size():
		var sameState = i == currentDayState
		if not sameState and animationPlayer.current_animation_position > dayColorList[i].startTime:
			currentDayState = i
			newState = true

	if newState:
		DayAnimationChange()

func DayAnimationChange():
	var state = dayColorList[currentDayState]

	var topColor: Color = state["top"]
	var horizonColor: Color = state["horizon"]
	var fogColor: Color = state["fog_color"]
	var fogDensity: float = state["fog_density"]

	var tween = create_tween()
	var duration = durationMultiplier

	# --- SKY ---
	tween.tween_property(
		worldEnvironment,
		"environment:sky:sky_material:sky_top_color",
		topColor,
		duration
	)
	tween.parallel()
	tween.tween_property(
		worldEnvironment,
		"environment:sky:sky_material:sky_horizon_color",
		horizonColor,
		duration
	)
	tween.parallel()
	tween.tween_property(
		worldEnvironment,
		"environment:sky:sky_material:ground_bottom_color",
		topColor,
		duration
	)
	tween.parallel()
	tween.tween_property(
		worldEnvironment,
		"environment:sky:sky_material:ground_horizon_color",
		horizonColor,
		duration
	)

	# --- VOLUMETRIC FOG ---
	tween.parallel()
	tween.tween_property(
		env,
		"volumetric_fog_albedo",
		fogColor,
		duration
	)

	tween.parallel()
	tween.tween_property(
		env,
		"volumetric_fog_density",
		fogDensity,
		duration
	)


func _process(delta: float) -> void:
	RefreshDayState()

func _input(event):
	if event.is_action_pressed("ui_page_up"):
		Engine.time_scale *= 2.0
		print("Time scale:", Engine.time_scale)

	if event.is_action_pressed("ui_page_down"):
		Engine.time_scale *= 0.5
		print("Time scale:", Engine.time_scale)
