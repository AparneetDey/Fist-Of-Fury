class_name EnemySlot
extends Node2D

var occupant : BasicEnemy = null

func isFree() -> bool:
	return occupant == null
	
func freeUp() -> void:
	occupant = null

func occupy(enemy: BasicEnemy) -> void:
	occupant = enemy
