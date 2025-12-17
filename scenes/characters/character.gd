class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var canRespawn : bool
@export var Damage : int
@export var DurationGrounded : int
@export var JumpIntensity : float
@export var KnockbackIntensity : float
@export var KnockdownIntensity : float
@export var MaxHealth : int
@export var Speed : float

@onready var animatedSprite := $AnimationPlayer
@onready var characterSprite := $CharacterSprite
@onready var damageEmitter := $DamageEmitter
@onready var damageReceiver : DamageReceiver = $DamageReceiver
@onready var collisionShape := $CollisionShape2D

enum State { IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH }

var animMap = {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt",
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.DEATH: "grounded",
}
var state := State.IDLE
var height := 0.0
var heightSpeed := 0.0
var currentHealth := 0
var timeGrounded := Time.get_ticks_msec()

func _ready() -> void:
	damageEmitter.area_entered.connect(onEmitDamage.bind())
	damageReceiver.damageReceived.connect(onReceiveDamage.bind())
	currentHealth = MaxHealth

func _process(delta: float) -> void:
	handleMovement()
	handleInput()
	handleAnimation()
	handleAirTime(delta)
	handleGroundedTime()
	handleDeath(delta)
	collisionShape.disabled = state == State.GROUNDED
	characterSprite.position = Vector2.UP * height
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
	if state == State.DEATH and not canRespawn:
		modulate.a -= delta
		if modulate.a <= 0:
			queue_free()
	
func handleAnimation() -> void:
	if animatedSprite.has_animation(animMap[state]):
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
			
func handleGroundedTime() -> void:
	if state == State.GROUNDED and (Time.get_ticks_msec() - timeGrounded) > DurationGrounded:
		if currentHealth <= 0:
			state = State.DEATH
		else:
			state = State.LAND

func flipCharacter() -> void:
	if velocity.x > 0:
		characterSprite.flip_h = false
		damageEmitter.scale.x = 1
	elif velocity.x < 0:
		characterSprite.flip_h = true
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
	return [State.IDLE, State.WALK, State.TAKEOFF, State.JUMP, State.LAND].has(state)
	
func onActionComplete() -> void:
	state = State.IDLE
	
func onTakeOffComplete() -> void:
	state = State.JUMP
	heightSpeed = JumpIntensity

func onEmitDamage(damageDealt : DamageReceiver) -> void:
	var hitType = DamageReceiver.HitType.NORMAL
	var direction = Vector2.LEFT if damageDealt.global_position.x < position.x else Vector2.RIGHT
	if state == State.JUMPKICK:
		hitType = DamageReceiver.HitType.KNOCKDOWN
	damageDealt.damageReceived.emit(Damage, direction, hitType)
	
func onReceiveDamage(damage : int, direction : Vector2, hitType: DamageReceiver.HitType) -> void:
	if canGetHurt():
		currentHealth = clamp(currentHealth - damage, 0, MaxHealth)
		if hitType == DamageReceiver.HitType.KNOCKDOWN or currentHealth == 0:
			state = State.FALL
			heightSpeed = KnockdownIntensity
		else:
			state = State.HURT
		velocity = direction * KnockbackIntensity
