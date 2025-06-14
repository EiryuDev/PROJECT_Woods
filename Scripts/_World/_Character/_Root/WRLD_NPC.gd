extends Interactable 

@export var dialoguePath := ""
@export var sound := ""
@onready var DialogueScene = preload("res://Resources/Prefabs/UI Objects/Dialogue Box.tscn")

signal hasTalkedAlready
var hasSignalEmitted = false
var hasDialogueStarted = false


func action_use():
	if !hasDialogueStarted:
		hasDialogueStarted = true
		var dialogueScene = DialogueScene.instantiate()
		dialogueScene.dialoguePath = self.dialoguePath
		dialogueScene.sound = self.sound
		dialogueScene.hasFinished.connect(DialogueFinished)
		add_child(dialogueScene)

func DialogueFinished():
	if !hasSignalEmitted:
		hasSignalEmitted = true
		emit_signal("hasTalkedAlready")
	hasDialogueStarted = false
