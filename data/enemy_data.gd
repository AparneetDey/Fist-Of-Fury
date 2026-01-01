class_name EnemyData
extends Resource

@export var type : Character.Type
@export var global_position : Vector2

func _init(enemyType : Character.Type = Character.Type.PUNK, enemyGlobalPosition : Vector2 = Vector2.ZERO) -> void:
	type = enemyType
	global_position = enemyGlobalPosition
