class_name EnemyData
extends Resource

const DROP_HEIGHT := 50

@export var doorIndex : int
@export var global_position : Vector2
@export var height : float
@export var state : Character.State
@export var type : Character.Type

func _init(enemyType : Character.Type = Character.Type.PUNK, enemyGlobalPosition : Vector2 = Vector2.ZERO, assignedDoorIndex : int = -1) -> void:
	type = enemyType
	if enemyGlobalPosition.y <= 0:
		height = DROP_HEIGHT
		state = Character.State.DROP
		global_position = enemyGlobalPosition + Vector2.DOWN * DROP_HEIGHT
	elif assignedDoorIndex > -1:
		doorIndex = assignedDoorIndex
		global_position = enemyGlobalPosition
	else:
		global_position = enemyGlobalPosition
		state = Character.State.IDLE
