extends Interactable 

@export var dialoguePath := ""
@export var sound := ""
@onready var DialogueScene = preload("res://Resources/Prefabs/UI Objects/Dialogue Box.tscn")
@onready var canvasLayer = $CanvasLayer

@export_group("ANIMATION SETTINGS")
@export var animationPlayer : AnimationPlayer
@export var requireAnimation = false

@export_group("QUEST SETTINGS")
@export var quest: Quest

signal hasTalkedAlready
var hasSignalEmitted = false
var hasDialogueStarted = false

func action_use():
	if !hasDialogueStarted:
		hasDialogueStarted = true
		if requireAnimation:
			animationPlayer.play("Talking")
		var dialogueScene = DialogueScene.instantiate()
		dialogueScene
		dialogueScene.dialoguePath = self.dialoguePath
		dialogueScene.sound = self.sound
		dialogueScene.hasFinished.connect(DialogueFinished)
		canvasLayer.add_child(dialogueScene)

func DialogueFinished():
	if requireAnimation:
		animationPlayer.play("Idle")
	if !hasSignalEmitted:
		hasSignalEmitted = true
		emit_signal("hasTalkedAlready")
	hasDialogueStarted = false
	quest.ReachedGoal()
	if quest.questStatus == quest.QuestStatus.reachedGoal:
		quest.FinishQuest()
