class_name Character
extends CharacterBody2D

const GRAVITY := 600.0

@export var Damage : int
@export var JumpIntensity : float
@export var knockbackIntensity : float
@export var MaxHealth : int
@export var Speed : float

@onready var animatedSprite := $AnimationPlayer
@onready var characterSprite := $CharacterSprite
@onready var damageEmitter := $DamageEmitter
@onready var damageReceiver : DamageReceiver = $DamageReceiver

enum State { IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT }

var animMap = {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt",
}
var state := State.IDLE
var height := 0.0
var heightSpeed := 0.0
var currentHealth := 0

func _ready() -> void:
	damageEmitter.area_entered.connect(onEmitDamage.bind())
	damageReceiver.damageReceived.connect(onReceiveDamage.bind())
	currentHealth = MaxHealth

func _process(delta: float) -> void:
	handleMovement()
	handleInput()
	handleAnimation()
	handleAirTime(delta)
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
	
func handleAnimation() -> void:
	if animatedSprite.has_animation(animMap[state]):
		animatedSprite.play(animMap[state])
		
func handleAirTime(delta : float) -> void:
	if state == State.JUMP or state==State.JUMPKICK:
		height += heightSpeed * delta
		if height < 0:
			height = 0
			state = State.LAND
		else:
			heightSpeed -= GRAVITY * delta

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
	
func onActionComplete() -> void:
	state = State.IDLE
	
func onTakeOffComplete() -> void:
	state = State.JUMP
	heightSpeed = JumpIntensity
	
func onLandComplete() -> void:
	state = State.IDLE

func onEmitDamage(damageReceived : DamageReceiver) -> void:
	var direction = Vector2.LEFT if damageReceived.global_position.x < position.x else Vector2.RIGHT
	damageReceived.damageReceived.emit(Damage, direction)
	
func onReceiveDamage(damage : int, direction : Vector2) -> void:
	currentHealth = clamp(currentHealth - damage, 0, MaxHealth)
	if currentHealth <= 0:
		queue_free()
	else:
		state = State.HURT
		velocity = direction * knockbackIntensity
