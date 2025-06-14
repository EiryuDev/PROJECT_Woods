extends ColorRect

@onready var indicator = $Indicator/IndicatorIcon

@export var dialoguePath := ""
@export var sound := ""
@export var textSpeed := 0.03 

var dialogue : Array

var phraseNum := 0
var finished := false
var canRecieveInput := false
signal hasFinished

func _ready():
	if sound != "":
		$AudioLetter.stream = load(sound)
		
	get_tree().get_first_node_in_group("Player").canMove = false
	get_tree().get_first_node_in_group("Player").velocity = Vector3.ZERO
	
	$Timer.wait_time = textSpeed
	dialogue = GetDialogue()
	assert(dialogue, "Dialogue not found")
	NextPhrase()
	await get_tree().create_timer(.3).timeout
	canRecieveInput = true


func _process(delta):
	indicator.visible = finished
	if canRecieveInput and Input.is_action_just_pressed("interact"):
		if finished:
			NextPhrase()
		else:
			$Text.visible_characters = len($Text.text)

func GetDialogue():
	var file = FileAccess.open(dialoguePath, FileAccess.READ)
	assert(file.file_exists(dialoguePath), "File Path does not exist")
	
	var json = file.get_as_text()
	var output  = JSON.parse_string(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return [] 

func NextPhrase():
	if phraseNum >= len(dialogue):
		get_tree().get_first_node_in_group("Player").canMove = true
		emit_signal("hasFinished")
		queue_free()
		return
		
	finished = false
	$Name.bbcode_text = dialogue[phraseNum]["Name"]
	$Text.bbcode_text = dialogue[phraseNum]["Text"]
	$Text.visible_characters = 0
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		$Timer.start()
		$AudioLetter.pitch_scale = randf_range(0.8, 1.2)
		$AudioLetter.play()
		await $Timer.timeout
		
	finished = true
	phraseNum += 1
	return
