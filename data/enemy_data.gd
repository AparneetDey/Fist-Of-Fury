class_name EnemyData
extends Resource

const DROP_HEIGHT := 50

@export var global_position : Vector2
@export var height : float
@export var state : Character.State
@export var type : Character.Type

func _init(enemyType : Character.Type = Character.Type.PUNK, enemyGlobalPosition : Vector2 = Vector2.ZERO) -> void:
	type = enemyType
	if enemyGlobalPosition.y <= 0:
		height = DROP_HEIGHT
		state = Character.State.DROP
		global_position = enemyGlobalPosition + Vector2.DOWN * DROP_HEIGHT
	else:
		global_position = enemyGlobalPosition
		state = Character.State.IDLE
