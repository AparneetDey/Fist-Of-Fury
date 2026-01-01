extends Node2D

@onready var camera := $Camera
@onready var player := $ActorsContainer/Player

var isCameraLocked := false

func _ready() -> void:
	StageManager.checkpointStart.connect(onCheckpointStart.bind())
	StageManager.checkpointCompleted.connect(onCheckpointCompleted.bind())

func _process(_delta: float) -> void:
	if player and not isCameraLocked and player.position.x > camera.position.x:
		camera.position.x = player.position.x

func onCheckpointStart() -> void:
	isCameraLocked = true

func onCheckpointCompleted() -> void:
	isCameraLocked = false
