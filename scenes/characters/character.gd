class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var CanRespawn : bool
@export var Damage : int
@export var MaxHealth : int
@export var type : Type

@export_group("Movement")
@export var DurationGrounded : int
@export var FlightSpeed : float
@export var JumpIntensity : float
@export var KnockbackIntensity : float
@export var KnockdownIntensity : float
@export var Speed : float

@export_group("Weapon")
@export var AutoDestroyOnDrop : bool
@export var CanRespawnKnives : bool
@export var DamageShot : int
@export var DamagePower : int
@export var DurationBetweenKnifeRespawn : int
@export var HasKnife : bool
@export var HasGun : bool
@export var MaxAmmoPerGun: int

@onready var animatedSprite := $AnimationPlayer
@onready var characterSprite := $CharacterSprite
@onready var damageEmitter := $DamageEmitter
@onready var damageReceiver : DamageReceiver = $DamageReceiver
@onready var collisionShape := $CollisionShape2D
@onready var collateralDamageEmitter := $CollateralDamageEmitter
@onready var knifeSprite := $KnifeSprite
@onready var projectileAim : RayCast2D = $ProjectileAim
@onready var collectibleSensor := $CollectibleSensor
@onready var weaponPosition := $KnifeSprite/WeaponPosition
@onready var gunSprite := $GunSprite

enum State { IDLE, WALK, ATTACK, TAKEOFF, JUMP , LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH, FLY, PREP_ATTACK, THROW, PICKUP, SHOOT, PREP_SHOOT, RECOVER, DROP, WAIT }
enum Type {PLAYER, PUNK, GOON, THUG, BOUNCER}

var animAttacks : Array = []
var animMap : Dictionary = {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt",
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.DEATH: "grounded",
	State.FLY: "fly",
	State.PREP_ATTACK: "prep_attack",
	State.THROW: "throw",
	State.PICKUP: "pickup",
	State.SHOOT: "shoot",
	State.PREP_SHOOT: "idle",
	State.RECOVER: "recover",
	State.DROP: "idle",
	State.WAIT: "idle"
}
var attackComboIndex := 0
var state := State.IDLE
var height := 0.0
var heightSpeed := 0.0
var heading := Vector2.RIGHT
var currentHealth := 0
var timeGrounded := Time.get_ticks_msec()
var timeSinceKnifeDismiss := Time.get_ticks_msec()
var is_last_hit_successful := false
var ammoLeft := 0

func _ready() -> void:
	damageEmitter.area_entered.connect(onEmitDamage.bind())
	damageReceiver.damageReceived.connect(onReceiveDamage.bind())
	collateralDamageEmitter.area_entered.connect(onEmitCollateralDamage.bind())
	collateralDamageEmitter.body_entered.connect(onWallHit.bind())
	setHealth(MaxHealth)
	setSpriteHeightPosition()

func _process(delta: float) -> void:
	handleMovement()
	handleInput()
	handleAnimation()
	handleAirTime(delta)
	handlePrepAttackTime()
	handlePrepShootTime()
	handleKnifeRespawn()
	handleGroundedTime()
	handleDeath(delta)
	onWaiting(delta)
	setSpriteVisibility()
	setSpriteHeightPosition()
	setUpCollisions()
	setHeading()
	flipCharacter()
	move_and_slide()

func handleMovement() -> void:
	if canMove():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

func handleInput() -> void:
	pass
	
func handleDeath(delta: float) -> void:
	if state == State.DEATH and not CanRespawn:
		modulate.a -= delta
		if modulate.a <= 0:
			queue_free()
	
func handleAnimation() -> void:
	if state == State.ATTACK:
		animatedSprite.play(animAttacks[attackComboIndex])
	elif animatedSprite.has_animation(animMap[state]):
		animatedSprite.play(animMap[state])
		
func handleAirTime(delta : float) -> void:
	if [State.JUMP, State.JUMPKICK, State.FALL, State.DROP].has(state):
		height += heightSpeed * delta
		if height < 0:
			height = 0
			if(state == State.FALL):
				state = State.GROUNDED
				timeGrounded = Time.get_ticks_msec()
			else:
				state = State.LAND
			velocity = Vector2.ZERO
		else:
			heightSpeed -= GRAVITY * delta

func handlePrepAttackTime() -> void:
	pass

func handlePrepShootTime() -> void:
	pass

func handleKnifeRespawn() -> void:
	if CanRespawnKnives and not HasKnife and (Time.get_ticks_msec() - timeSinceKnifeDismiss) > DurationBetweenKnifeRespawn:
		HasKnife = true

func handleGroundedTime() -> void:
	if state == State.GROUNDED and (Time.get_ticks_msec() - timeGrounded) > DurationGrounded:
		if currentHealth <= 0:
			state = State.DEATH
		else:
			state = State.LAND

func handlePickup() -> void:
	if canPickupCollectible():
		var collectibleAreas : Array = collectibleSensor.get_overlapping_areas()
		var collectible : Collectible = collectibleAreas[0]
		if collectible.type == Collectible.Type.KNIFE and not isCarryingWeapon():
			HasKnife = true
		if collectible.type == Collectible.Type.GUN and not isCarryingWeapon():
			HasGun = true
			ammoLeft = MaxAmmoPerGun
		if collectible.type == Collectible.Type.FOOD:
			setHealth(MaxHealth)
		collectible.queue_free()

func handleGunShot() -> void:
	state = State.SHOOT
	velocity = Vector2.ZERO
	var weaponRootPosition = Vector2(weaponPosition.global_position.x, global_position.y)
	var gunHeight = -weaponPosition.position.y
	var targetPosition = heading * (global_position.x + get_viewport_rect().size.x)
	var target = projectileAim.get_collider()
	if target != null:
		targetPosition = heading * projectileAim.get_collision_point()
		target.onReceiveDamage(DamageShot, heading, DamageReceiver.HitType.KNOCKDOWN)
	var distance : float = targetPosition.x - weaponPosition.position.x
	EntityManager.spawnShot.emit(weaponRootPosition, distance, gunHeight)

func setHeading() -> void:
	pass

func setSpriteVisibility() -> void:
	knifeSprite.visible = HasKnife
	gunSprite.visible = HasGun

func setSpriteHeightPosition() -> void:
	characterSprite.position = Vector2.UP * height
	knifeSprite.position = Vector2.UP * height
	gunSprite.position = Vector2.UP * height

func setUpCollisions() -> void:
	collisionShape.disabled = isCollisionDisabled()
	damageEmitter.monitoring = isAttacking()
	damageReceiver.monitorable = canGetHurt()
	collateralDamageEmitter.monitoring = state == State.FLY

func setHealth(health: int):
	currentHealth = clamp(health, 0 , MaxHealth)
	DamageManager.healthChange.emit(type, currentHealth, MaxHealth)

func flipCharacter() -> void:
	if heading == Vector2.RIGHT:
		characterSprite.flip_h = false
		knifeSprite.scale.x = 1
		gunSprite.scale.x = 1
		projectileAim.scale.x = 1
		damageEmitter.scale.x = 1
	else:
		characterSprite.flip_h = true
		knifeSprite.scale.x = -1
		gunSprite.scale.x = -1
		projectileAim.scale.x = -1
		damageEmitter.scale.x = -1
	
func canMove() -> bool:
	return state == State.IDLE or state == State.WALK
	
func canAttack() -> bool:
	return state == State.IDLE or state == State.WALK
	
func canJumpKick() -> bool:
	return state == State.JUMP
	
func canJump() -> bool:
	return state == State.IDLE or state == State.WALK
	
func canGetHurt() -> bool:
	return [State.IDLE, State.WALK, State.TAKEOFF, State.HURT, State.ATTACK, State.PREP_ATTACK, State.PREP_SHOOT].has(state)

func canPickupCollectible() -> bool:
	if CanRespawnKnives:
		return false
	if (Time.get_ticks_msec() - timeSinceKnifeDismiss) < DurationBetweenKnifeRespawn:
		return false
	var collectibleAreas : Array = collectibleSensor.get_overlapping_areas()
	if collectibleAreas.size() == 0:
		return false
	var collectible : Collectible = collectibleAreas[0]
	if collectible.type == Collectible.Type.KNIFE and not isCarryingWeapon():
		return true
	if collectible.type == Collectible.Type.GUN and not isCarryingWeapon():
		return true
	if collectible.type == Collectible.Type.FOOD and currentHealth < MaxHealth and CanRespawn:
		return true
	return false

func isCarryingWeapon() -> bool:
	return HasKnife or HasGun

func isCollisionDisabled() -> bool:
	return [State.GROUNDED, State.DEATH, State.FLY, State.FALL, State.DROP].has(state)

func isAttacking() -> bool:
	return [State.ATTACK, State.JUMPKICK].has(state)

func onWaiting(_delta) -> void:
	pass

func onActionComplete() -> void:
	state = State.IDLE

func onThrowComplete() -> void:
	state = State.IDLE
	var collectibleType := Collectible.Type.KNIFE
	if HasGun:
		collectibleType = Collectible.Type.GUN
		HasGun = false
	else:
		HasKnife = false
	var collectibleGlobalPosition := Vector2(weaponPosition.global_position.x, global_position.y)
	var collectibleHeight : float = -weaponPosition.position.y
	EntityManager.spawnCollectible.emit(collectibleType, Collectible.State.FLY, collectibleGlobalPosition, heading, collectibleHeight, false)

func onPickupComplete() -> void:
	state = State.IDLE
	handlePickup()

func onTakeOffComplete() -> void:
	state = State.JUMP
	heightSpeed = JumpIntensity

func onEmitDamage(receiver : DamageReceiver) -> void:
	var hitType = DamageReceiver.HitType.NORMAL
	var currentDamage := Damage
	var direction = Vector2.LEFT if receiver.global_position.x < position.x else Vector2.RIGHT
	if state == State.JUMPKICK:
		hitType = DamageReceiver.HitType.KNOCKDOWN
	if attackComboIndex == animAttacks.size() - 1 and state != State.JUMPKICK:
		hitType = DamageReceiver.HitType.POWER
		currentDamage = DamagePower
	receiver.damageReceived.emit(currentDamage, direction, hitType)
	is_last_hit_successful = true
	
func onReceiveDamage(damage : int, direction : Vector2, hitType: DamageReceiver.HitType) -> void:
	if canGetHurt():
		setHealth(currentHealth - damage)
		
		CanRespawnKnives = false
		attackComboIndex = 0
		if HasKnife:
			HasKnife = false
			timeSinceKnifeDismiss = Time.get_ticks_msec()
			EntityManager.spawnCollectible.emit(Collectible.Type.KNIFE, Collectible.State.FALL, global_position, Vector2.ZERO, 0.0, AutoDestroyOnDrop)
		if HasGun:
			HasGun = false
			timeSinceKnifeDismiss = Time.get_ticks_msec()
			EntityManager.spawnCollectible.emit(Collectible.Type.GUN, Collectible.State.FALL, global_position, Vector2.ZERO, 0.0, AutoDestroyOnDrop)
		
		if hitType == DamageReceiver.HitType.KNOCKDOWN or currentHealth == 0:
			state = State.FALL
			heightSpeed = KnockdownIntensity
			velocity = direction * KnockbackIntensity
		elif hitType == DamageReceiver.HitType.POWER:
			state = State.FLY
			velocity = direction * FlightSpeed
		else:
			state = State.HURT
			velocity = direction * KnockbackIntensity

func onEmitCollateralDamage(receiver : DamageReceiver) -> void:
	if receiver != damageReceiver:
		var direction = Vector2.LEFT if receiver.global_position.x < position.x else Vector2.RIGHT
		receiver.damageReceived.emit(0, direction, receiver.HitType.KNOCKDOWN)
	
func onWallHit(_wall : AnimatableBody2D) -> void:
	state = State.FALL
	heightSpeed = KnockdownIntensity
	velocity = -velocity / 2.0
