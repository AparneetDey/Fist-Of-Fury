class_name IgorBoss
extends Character

@export var DistanceFromPlayer : int
@export var player : Player

func getTargetPosition() -> Vector2:
	var target := Vector2.ZERO
	if position.x < player.position.x:
		target = player.position + Vector2.LEFT * DistanceFromPlayer
	else:
		target = player.position + Vector2.RIGHT * DistanceFromPlayer
	return target

func isPlayerWithInRange() -> bool:
	var target := getTargetPosition()
	return (target - position).length() < 1

func handleInput() -> void:
	if player != null and canMove():
		if isPlayerWithInRange():
			velocity = Vector2.ZERO
			state = State.IDLE
		else:
			var targetPosition := getTargetPosition()
			var direction = (targetPosition - position).normalized()
			velocity = direction * Speed
			state = State.WALK

func setHeading() -> void:
	if player == null and not canMove():
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT
