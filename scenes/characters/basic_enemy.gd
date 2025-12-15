class_name BasicEnemy
extends Character

@export var player : Player

func handleInput() -> void:
	if player != null and canMove():
		var direction := (player.position - position).normalized()
		#velocity = direction*Speed
