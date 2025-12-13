extends CharacterBody2D

@export var damage : int
@export var health : int
@export var speed : float

@onready var animatedSprite := $AnimationPlayer
@onready var characterSprite := $CharacterSprite
@onready var damageEmitter := $DamageEmitter

enum State { IDLE, WALK, ATTACK }
var state := State.IDLE

func _ready() -> void:
	damageEmitter.area_entered.connect(onEmitDamage.bind())

func _process(_delta: float) -> void:
	handleMovement()
	handleInput()
	handleAnimation()
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
	if canAttack() && Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	
func handleAnimation() -> void:
	if state == State.IDLE:
		animatedSprite.play("idle")
	elif  state == State.WALK:
		animatedSprite.play("walk")
	elif state == State.ATTACK:
		animatedSprite.play("punch")

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
	
func onActionComplete() -> void:
	state = State.IDLE

func onEmitDamage(damageReceiver : DamageReceiver) -> void:
	var direction = Vector2.LEFT if damageReceiver.global_position.x < position.x else Vector2.RIGHT
	damageReceiver.damageReceived.emit(damage, direction)
