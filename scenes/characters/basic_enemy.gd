class_name BasicEnemy
extends Character

@export var player : Player
@export var DurationBetweenAttacks : int
@export var DurationPrepAttack : int

var playerSlot : EnemySlot = null
var timeSinceLastAttacked := Time.get_ticks_msec()
var timeOfPrepAttack := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	animAttacks = ["punch", "punch_alt"]

func handleInput() -> void:
	if player != null and canMove():
		
		if playerSlot == null:
			playerSlot = player.reserveSlot(self)
			
		if playerSlot != null:
			var direction := (playerSlot.global_position - global_position).normalized()
			if isPlayerWithInRange():
				velocity = Vector2.ZERO
				if canAttack() and (Time.get_ticks_msec() - timeSinceLastAttacked) > DurationBetweenAttacks and player.currentHealth != 0:
					state = State.PREP_ATTACK
					timeOfPrepAttack = Time.get_ticks_msec()
			else:
				velocity = direction*Speed

func handlePrepAttackTime() -> void:
	if state == State.PREP_ATTACK and (Time.get_ticks_msec() - timeOfPrepAttack) > DurationPrepAttack:
		state = State.ATTACK
		animAttacks.shuffle()
		timeSinceLastAttacked = Time.get_ticks_msec()

func setHeading() -> void:
	if player != null:
		if player.global_position.x > global_position.x:
			heading = Vector2.RIGHT
		else:
			heading = Vector2.LEFT

func onReceiveDamage(damage : int, direction : Vector2, hitType : DamageReceiver.HitType) -> void:
	super.onReceiveDamage(damage, direction, hitType)
	if currentHealth <= 0:
		player.freeSlot(self)

func isPlayerWithInRange() -> bool:
	return (playerSlot.global_position - global_position).length() < 1

func canAttack() -> bool:
	if (Time.get_ticks_msec() - timeSinceLastAttacked) < DurationBetweenAttacks:
		return false
	return super.canAttack()
