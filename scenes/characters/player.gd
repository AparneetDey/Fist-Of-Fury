class_name Player
extends Character

@onready var enemySlots : Array = $EnemySlots.get_children()

func handleInput() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction*Speed
	if canAttack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
		if is_last_hit_successful:
			attackComboIndex = (attackComboIndex + 1) % animAttacks.size()
			is_last_hit_successful = false
		else:
			attackComboIndex = 0
	if canJump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	if canJumpKick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK

func reserveSlot(enemy: BasicEnemy) -> EnemySlot:
	var vacantSlot := enemySlots.filter(
		func(slot: EnemySlot): return slot.isFree()
	)
	
	if vacantSlot.size() == 0:
		return null
		
	vacantSlot.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dist_a = (enemy.global_position - a.global_position).length()
			var dist_b = (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	
	vacantSlot[0].occupy(enemy)
	return vacantSlot[0]

func freeSlot(enemy: BasicEnemy) -> void:
	var targetSlot := enemySlots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	
	if targetSlot.size() == 1:
		targetSlot[0].freeUp()
