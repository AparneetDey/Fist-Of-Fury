extends Node2D

const STAGE_PREFAB := [
	preload("res://scenes/stages/stage_01_streets.tscn"),
	preload("res://scenes/stages/stage_02_bar.tscn"),
]
const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")

@onready var actorsContainer := $ActorsContainer
@onready var camera := $Camera
@onready var stageContainers := $StageContainer
@onready var stageTransition : StageTransition = $UI/UIControls/StageTransition

var currentStageIndex := -1
var isCameraLocked := false
var isStageReadyForLoading := false
var player : Player = null
var cameraInitialPosition := Vector2.ZERO

func _ready() -> void:
	cameraInitialPosition = camera.position
	StageManager.checkpointStart.connect(onCheckpointStart.bind())
	StageManager.checkpointCompleted.connect(onCheckpointCompleted.bind())
	StageManager.stageInterim.connect(loadNextStage.bind())
	StageManager.gameRestart.connect(onGameRestart.bind())
	loadNextStage()

func _process(_delta: float) -> void:
	if isStageReadyForLoading:
		isStageReadyForLoading = false
		var stage : Stage = STAGE_PREFAB[currentStageIndex].instantiate()
		stageContainers.add_child(stage)
		player = PLAYER_PREFAB.instantiate()
		actorsContainer.add_child(player)
		actorsContainer.player = player
		player.position = stage.getPlayerPosition()
		camera.position = cameraInitialPosition
		stageTransition.endTransition()
	
	if player and not isCameraLocked and player.position.x > camera.position.x:
		camera.position.x = player.position.x

func loadNextStage() -> void:
	currentStageIndex += 1
	if currentStageIndex < STAGE_PREFAB.size():
		for actor in actorsContainer.get_children():
			actor.queue_free()
		for stage : Stage in stageContainers.get_children():
			stage.queue_free()
		isStageReadyForLoading = true
	else:
		StageManager.gameComplete.emit()

func onGameRestart() -> void:
	print("restart")
	currentStageIndex = -1
	loadNextStage()

func onCheckpointStart() -> void:
	isCameraLocked = true

func onCheckpointCompleted(_checkpoint: Checkpoint) -> void:
	isCameraLocked = false
