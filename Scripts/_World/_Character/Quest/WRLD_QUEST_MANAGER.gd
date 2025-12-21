extends Node3D
class_name QuestManager

@export_group("Quest Settings")
@export var questName : String
@export var questDescription : String
@export var reachedGoalText : String

enum QuestStatus {
	available,
	started,
	reachedGoal,
	finished
}

@export var questStatus : QuestStatus = QuestStatus.available

@export_group("Reward Settings")
@export var rewardAmount : int
@export var xpAmount : int
