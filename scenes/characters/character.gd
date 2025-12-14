extends CharacterBody2D

const GRAVITY := 600.0

@export var damage : int
@export var health : int
@export var heightIntensity : float
@export var speed : float

@onready var animatedSprite := $AnimationPlayer
@onready var characterSprite := $CharacterSprite
@onready var damageEmitter := $DamageEmitter

enum State { IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK }

var animMap = {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
}
var state := State.IDLE
var height := 0.0
var heightSpeed := 0.0

func _ready() -> void:
	damageEmitter.area_entered.connect(onEmitDamage.bind())

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
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction*speed
	if canAttack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	if canJump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	if canJumpKick() and Input.is_action_just_pressed("attack"):
		state = State.JUMPKICK
	
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
	heightSpeed = heightIntensity
	
func onLandComplete() -> void:
	state = State.IDLE

func onEmitDamage(damageReceiver : DamageReceiver) -> void:
	var direction = Vector2.LEFT if damageReceiver.global_position.x < position.x else Vector2.RIGHT
	damageReceiver.damageReceived.emit(damage, direction)
