class_name Player
extends Character

func handleInput() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction*Speed
	if canAttack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	if canJump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	if canJumpKick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK
