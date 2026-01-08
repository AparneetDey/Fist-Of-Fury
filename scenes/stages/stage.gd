class_name Stage
extends Node2D

@export var music : MusicManager.Music

@onready var playerStartPosition := $PlayerStartPosition
@onready var containers := $Containers
@onready var doors := $Doors
@onready var checkpoints := $Checkpoints

func _init() -> void:
	StageManager.checkpointCompleted.connect(onCheckpointCompleted.bind())

func _ready() -> void:
	for container : Node2D in containers.get_children():
		EntityManager.orphanActor.emit(container)
	
	for i in range(doors.get_child_count()):
		var door : Door = doors.get_child(i)
		for enemy in door.Enemies:
			enemy.assignedDoorIndex = i
	
	for door : Door in doors.get_children():
		EntityManager.orphanActor.emit(door)
	
	for checkpoint : Checkpoint in checkpoints.get_children():
		checkpoint.createEnemyData()
	
	MusicPlayer.play(music)

func getPlayerPosition() -> Vector2:
	return playerStartPosition.position

func onCheckpointCompleted(checkpoint: Checkpoint) -> void:
	if checkpoints.get_child(-1) == checkpoint:
		StageManager.stageCompleted.emit()
