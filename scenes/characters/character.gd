class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var CanRespawn : bool
@export var CanRespawnKnives : bool
@export var Damage : int
@export var DamagePower : int
@export var DurationGrounded : int
@export var DurationBetweenKnifeRespawn : int
@export var FlightSpeed : float
@export var JumpIntensity : float
@export var HasKnife : bool
@export var KnockbackIntensity : float
@export var KnockdownIntensity : float
@export var MaxHealth : int
@export var Speed : float

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

enum State { IDLE, WALK, ATTACK, TAKEOFF, JUMP , LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH, FLY, PREP_ATTACK, THROW, PICKUP }

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
	State.PREP_ATTACK: "idle",
	State.THROW: "throw",
	State.PICKUP: "pickup"
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

func _ready() -> void:
	damageEmitter.area_entered.connect(onEmitDamage.bind())
	damageReceiver.damageReceived.connect(onReceiveDamage.bind())
	collateralDamageEmitter.area_entered.connect(onEmitCollateralDamage.bind())
	collateralDamageEmitter.body_entered.connect(onWallHit.bind())
	currentHealth = MaxHealth

func _process(delta: float) -> void:
	handleMovement()
	handleInput()
	handleAnimation()
	handleAirTime(delta)
	handlePrepAttackTime()
	handleKnifeRespawn()
	handleGroundedTime()
	handleDeath(delta)
	collisionShape.disabled = isCollisionDisabled()
	knifeSprite.visible = HasKnife
	characterSprite.position = Vector2.UP * height
	knifeSprite.position = Vector2.UP * height
	damageEmitter.monitoring = isAttacking()
	damageReceiver.monitorable = canGetHurt()
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
	if [State.JUMP, State.JUMPKICK, State.FALL].has(state):
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
		if collectible.type == Collectible.Type.KNIFE and not HasKnife:
			HasKnife = true
		collectible.queue_free()

func setHeading() -> void:
	pass

func flipCharacter() -> void:
	if heading == Vector2.RIGHT:
		characterSprite.flip_h = false
		knifeSprite.scale.x = 1
		projectileAim.scale.x = 1
		damageEmitter.scale.x = 1
	else:
		characterSprite.flip_h = true
		knifeSprite.scale.x = -1
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
	return [State.IDLE, State.WALK, State.TAKEOFF, State.HURT, State.ATTACK, State.PREP_ATTACK].has(state)

func canPickupCollectible() -> bool:
	var collectibleAreas : Array = collectibleSensor.get_overlapping_areas()
	if collectibleAreas.size() == 0:
		return false
	var collectible : Collectible = collectibleAreas[0]
	if collectible.type == Collectible.Type.KNIFE and not HasKnife:
		return true
	return false

func isCollisionDisabled() -> bool:
	return [State.GROUNDED, State.DEATH, State.FLY, State.FALL].has(state)

func isAttacking() -> bool:
	return [State.ATTACK, State.JUMPKICK].has(state)
	
func onActionComplete() -> void:
	state = State.IDLE

func onThrowComplete() -> void:
	state = State.IDLE
	HasKnife = false
	var knifeGlobalPosition := Vector2(weaponPosition.global_position.x, global_position.y)
	var knifeHeight : float = -weaponPosition.position.y
	EntityManager.spawnCollectible.emit(Collectible.Type.KNIFE, Collectible.State.FLY, knifeGlobalPosition, heading, knifeHeight)

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
		CanRespawnKnives = false
		if HasKnife:
			HasKnife = false
			timeSinceKnifeDismiss = Time.get_ticks_msec()
		currentHealth = clamp(currentHealth - damage, 0, MaxHealth)
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
