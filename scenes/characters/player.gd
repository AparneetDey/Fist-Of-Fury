class_name Player
extends Character

@export var DurationBetweenLastSuccessfulHit : int

@onready var enemySlots : Array = $EnemySlots.get_children()

var timeSinceLastSuccessfulHit := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	animAttacks = ["punch", "punch_alt", "kick", "round_kick"]

func _process(delta: float) -> void:
	super._process(delta)
	processTimeBetweenCombos()

func processTimeBetweenCombos() -> void:
	if (Time.get_ticks_msec() - timeSinceLastSuccessfulHit) > DurationBetweenLastSuccessfulHit:
		attackComboIndex = 0

func handleInput() -> void:
	if canMove():
		var direction := Input.get_vector("left", "right", "up", "down")
		velocity = direction*Speed
	if canAttack() and Input.is_action_just_pressed("attack"):
		if HasKnife:
			state = State.THROW
		elif HasGun:
			if ammoLeft > 0:
				handleGunShot()
				ammoLeft -= 1
			else:
				state = State.THROW
		else:
			if canPickupCollectible():
				state = State.PICKUP
			else:
				state = State.ATTACK
				SoundPlayer.play(SoundManager.Sound.SWOOSH, true)
				if is_last_hit_successful:
					timeSinceLastSuccessfulHit = Time.get_ticks_msec()
					attackComboIndex = (attackComboIndex + 1) % animAttacks.size()
					is_last_hit_successful = false
				else:
					attackComboIndex = 0
	if canJump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	if canJumpKick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK
		attackComboIndex = 0
		SoundPlayer.play(SoundManager.Sound.SWOOSH, true)

func setHeading() -> void:
	if canMove():
		if velocity.x > 0:
			heading = Vector2.RIGHT
		elif velocity.x < 0:
			heading = Vector2.LEFT

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
