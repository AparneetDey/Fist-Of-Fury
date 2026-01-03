class_name IgorBoss
extends Character

const GROUND_FRICTION := 50

@export var DistanceFromPlayer : int
@export var DurationBetweenAttacks : int
@export var DurationVulnerable : int
@export var DurationPrepAttackTime : int
@export var player : Player

var knockbackForce := Vector2.ZERO
var timeSinceLastAttacked := Time.get_ticks_msec()
var timeSinceVulnerable := Time.get_ticks_msec()
var timeSincePrepAttack := Time.get_ticks_msec()

func _process(delta: float) -> void:
	super._process(delta)
	knockbackForce = knockbackForce.move_toward(Vector2.ZERO, delta * GROUND_FRICTION)

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
		if canAttack() and projectileAim.is_colliding():
			state = State.PREP_ATTACK
			velocity = Vector2.ZERO
			timeSincePrepAttack = Time.get_ticks_msec()
		else:
			if isPlayerWithInRange():
				velocity = Vector2.ZERO
				state = State.IDLE
			else:
				var targetPosition := getTargetPosition()
				var direction = (targetPosition - position).normalized()
				velocity = (direction + knockbackForce) * Speed
				state = State.WALK

func handleGroundedTime() -> void:
	if state == State.GROUNDED and currentHealth > 0:
		state = State.RECOVER
		timeSinceVulnerable = Time.get_ticks_msec()
	elif state == State.RECOVER and (Time.get_ticks_msec() - timeSinceVulnerable) > DurationVulnerable:
		state = State.IDLE
		timeSinceLastAttacked = Time.get_ticks_msec()

func handlePrepAttackTime() -> void:
	if state == State.PREP_ATTACK and (Time.get_ticks_msec() - timeSincePrepAttack) > DurationPrepAttackTime:
		state = State.FLY
		velocity = heading * FlightSpeed

func setHeading() -> void:
	if player != null and canMove():
		heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT

func canGetHurt() -> bool:
	return true

func canAttack() -> bool:
	if (Time.get_ticks_msec() - timeSinceLastAttacked) < DurationBetweenAttacks:
		return false
	return super.canAttack()

func isVulnerable() -> bool:
	return state == State.RECOVER

func onActionComplete() -> void:
	if state == State.HURT:
		state = State.RECOVER
		return
	super.onActionComplete()

func onReceiveDamage(damage : int, direction : Vector2, _hitType: DamageReceiver.HitType) -> void:
	if not isVulnerable():
		knockbackForce = direction * KnockbackIntensity
		return
	ComboManager.registerHit.emit()
	currentHealth = clamp(currentHealth - damage, 0, MaxHealth)
	if currentHealth <= 0:
		state = State.FALL
		heightSpeed = KnockdownIntensity
		velocity = direction * KnockbackIntensity
		EntityManager.deathEnemy.emit()
	else:
		velocity = Vector2.ZERO
		state = State.HURT

func onEmitDamage(receiver : DamageReceiver) -> void:
	receiver.damageReceived.emit(Damage, heading, DamageReceiver.HitType.KNOCKDOWN)
	state = State.IDLE
	timeSinceLastAttacked = Time.get_ticks_msec()

func isAttacking() -> bool:
	return state == State.FLY
