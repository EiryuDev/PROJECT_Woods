class_name Quest extends QuestManager

@export var activeQuest = false
@export var player : PlayerManager
@export var audioPlayer : AudioStreamPlayer2D

func StartQuest() -> void:
	if questStatus == QuestStatus.available:
		questStatus = QuestStatus.started
		player.playerUIManager.questPanel.visible = true
		player.playerUIManager.questTitle.text = questName
		player.playerUIManager.questDescription.text = questDescription
		
func ReachedGoal() -> void:
	if questStatus == QuestStatus.started:
		questStatus = QuestStatus.reachedGoal
		player.playerUIManager.questDescription.text = reachedGoalText
		
func FinishQuest() -> void:
	if questStatus == QuestStatus.reachedGoal:
		audioPlayer.play()
		questStatus = QuestStatus.finished
		player.playerUIManager.questPanel.visible = false
		
func _ready():
	if activeQuest:
		StartQuest()
