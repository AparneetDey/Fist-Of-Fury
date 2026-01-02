class_name BasicEnemy
extends Character

const SCREEN_EDGE_BUFFER := 10

@export var player : Player
@export var DurationBetweenMeleeAttack : int
@export var DurationBetweenRangeAttack : int
@export var DurationPrepMeleeAttack : int
@export var DurationPrepRangeAttack : int

var assignedDoorIndex := -1
var playerSlot : EnemySlot = null
var timeSinceLastMeleeAttacked := Time.get_ticks_msec()
var timeSinceLastRangeAttacked := Time.get_ticks_msec()
var timeOfPrepMeleeAttack := Time.get_ticks_msec()
var timeOfPrepRangeAttack := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	animAttacks = ["punch", "punch_alt"]

func handleInput() -> void:
	if player != null and canMove():
		if CanRespawnKnives or HasKnife or HasGun:
			handleRangeAttack()
		else:
			handleMeleeAttack()

func handleMeleeAttack() -> void:
	if canPickupCollectible():
		state = State.PICKUP
		if playerSlot != null:
			player.freeSlot(self)
	elif playerSlot == null:
		playerSlot = player.reserveSlot(self)
		
	if playerSlot != null:
		var direction := (playerSlot.global_position - global_position).normalized()
		if isPlayerWithInRange():
			velocity = Vector2.ZERO
			if canAttack() and (Time.get_ticks_msec() - timeSinceLastMeleeAttacked) > DurationBetweenMeleeAttack and player.currentHealth != 0:
				state = State.PREP_ATTACK
				timeOfPrepMeleeAttack = Time.get_ticks_msec()
		else:
			velocity = direction*Speed

func handleRangeAttack() -> void:
	var camera := get_viewport().get_camera_2d()
	var screenWidth := get_viewport_rect().size.x
	
	var screenLeftEdge = camera.position.x - screenWidth / 2
	var screenRightEdge = camera.position.x + screenWidth / 2
	
	var leftDestination := Vector2(screenLeftEdge + SCREEN_EDGE_BUFFER, player.position.y)
	var rightDestination := Vector2(screenRightEdge - SCREEN_EDGE_BUFFER, player.position.y)
	var closestDestination := Vector2.ZERO
	
	if (leftDestination - position).length() < (rightDestination - position).length():
		closestDestination = leftDestination
	else:
		closestDestination = rightDestination
	
	if (closestDestination - position).length() < 1:
		velocity = Vector2.ZERO
	else:
		velocity = (closestDestination - position).normalized() * Speed
		
	if canRangeAttack() and HasKnife and projectileAim.is_colliding():
		state = State.THROW
		timeSinceLastRangeAttacked = Time.get_ticks_msec()
		timeOfPrepRangeAttack = Time.get_ticks_msec()
		timeSinceKnifeDismiss = Time.get_ticks_msec()
	
	if canRangeAttack() and HasGun and projectileAim.is_colliding():
		state = State.PREP_SHOOT
		velocity = Vector2.ZERO
		timeOfPrepRangeAttack = Time.get_ticks_msec()

func handlePrepAttackTime() -> void:
	if state == State.PREP_ATTACK and (Time.get_ticks_msec() - timeOfPrepMeleeAttack) > DurationPrepMeleeAttack:
		state = State.ATTACK
		animAttacks.shuffle()
		timeSinceLastMeleeAttacked = Time.get_ticks_msec()

func handlePrepShootTime() -> void:
	if state == State.PREP_SHOOT and (Time.get_ticks_msec() - timeOfPrepRangeAttack) > DurationPrepRangeAttack:
		handleGunShot()
		timeSinceLastRangeAttacked = Time.get_ticks_msec()

func handleAssignedDoor(door : Door) -> void:
	if door.state != Door.State.OPENED:
		state = State.WAIT
		door.open()
		door.doorOpen.connect(onActionComplete.bind())

func setHeading() -> void:
	if player != null and canMove():
		if player.global_position.x > global_position.x:
			heading = Vector2.RIGHT
		else:
			heading = Vector2.LEFT

func onReceiveDamage(damage : int, direction : Vector2, hitType : DamageReceiver.HitType) -> void:
	super.onReceiveDamage(damage, direction, hitType)
	if currentHealth <= 0:
		player.freeSlot(self)
		EntityManager.deathEnemy.emit()

func isPlayerWithInRange() -> bool:
	return (playerSlot.global_position - global_position).length() < 1

func canAttack() -> bool:
	if (Time.get_ticks_msec() - timeSinceLastMeleeAttacked) < DurationBetweenMeleeAttack:
		return false
	return super.canAttack()

func canRangeAttack() -> bool:
	if (Time.get_ticks_msec() - timeSinceLastRangeAttacked) < DurationBetweenRangeAttack:
		return false
	return super.canAttack()
