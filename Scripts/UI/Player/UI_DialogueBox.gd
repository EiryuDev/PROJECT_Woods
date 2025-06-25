extends ColorRect

@onready var indicator = $Indicator/IndicatorIcon
@onready var choiceBox = $"Choice Box"
@onready var firstChoiceBox = $"Choice Box/Choice Button"
@onready var secondChoiceBox = $"Choice Box/Choice Button2"

@export var dialoguePath := ""
@export var sound := ""
@export var textSpeed := 0.03 

var dialogue : Array

var phraseNum := 0
var finished := false
var canRecieveInput := false
signal hasFinished

# === New choice navigation support ===
var selected_choice := 0
var choice_buttons := []

func _ready():
	if sound != "":
		$AudioLetter.stream = load(sound)
	get_tree().get_first_node_in_group("Player").canMove = false
	get_tree().get_first_node_in_group("Player").velocity = Vector3.ZERO

	$Timer.wait_time = textSpeed
	dialogue = GetDialogue()
	assert(dialogue, "Dialogue not found")
	NextPhrase()
	await get_tree().create_timer(0.3).timeout
	canRecieveInput = true

func _process(delta):
	indicator.visible = finished and not choiceBox.visible

	if choiceBox.visible:
		if Input.is_action_just_pressed("ui_down"):
			selected_choice = (selected_choice + 1) % choice_buttons.size()
			_update_choice_focus()
		elif Input.is_action_just_pressed("ui_up"):
			selected_choice = (selected_choice - 1 + choice_buttons.size()) % choice_buttons.size()
			_update_choice_focus()
		elif Input.is_action_just_pressed("interact"):
			choice_buttons[selected_choice].emit_signal("pressed")
	else:
		if canRecieveInput and Input.is_action_just_pressed("interact"):
			if finished:
				NextPhrase()
			else:
				$Text.visible_characters = len($Text.text)

func GetDialogue():
	var file = FileAccess.open(dialoguePath, FileAccess.READ)
	assert(file.file_exists(dialoguePath), "File Path does not exist")
	var json = file.get_as_text()
	var output = JSON.parse_string(json)
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

	var current = dialogue[phraseNum]

	if "choice" in current and current["choice"] == true:
		ShowChoices(current["choices"])
		return

	finished = false
	$Name.bbcode_text = current.get("Name", "")
	$Text.bbcode_text = current.get("Text", "")
	$Text.visible_characters = 0

	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		$Timer.start()
		$AudioLetter.pitch_scale = randf_range(0.8, 1.2)
		$AudioLetter.play()
		await $Timer.timeout

	finished = true

	# ✅ Instead of incrementing, read `next`
	if current.has("next") and current["next"] != null:
		phraseNum = current["next"]
	else:
		# If there's no "next", treat this as the end of the dialogue
		get_tree().get_first_node_in_group("Player").canMove = true
		emit_signal("hasFinished")
		queue_free()



func ShowChoices(choices):
	canRecieveInput = false
	choiceBox.visible = true

	firstChoiceBox.text = choices[0]["text"]
	secondChoiceBox.text = choices[1]["text"]

	# Connect button press signals
	firstChoiceBox.pressed.connect(func(): HandleChoice(choices[0]["next"]))
	secondChoiceBox.pressed.connect(func(): HandleChoice(choices[1]["next"]))

	# Keyboard navigation support
	choice_buttons = [firstChoiceBox, secondChoiceBox]
	selected_choice = 0
	_update_choice_focus()

func HandleChoice(next_index):
	choiceBox.visible = false
	phraseNum = next_index
	canRecieveInput = true
	NextPhrase()

func _update_choice_focus():
	for i in range(choice_buttons.size()):
		if i == selected_choice:
			choice_buttons[i].grab_focus()
