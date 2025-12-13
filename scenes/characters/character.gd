extends CharacterBody2D

@export var damage : int
@export var health : int
@export var speed : float

@onready var animatedSprite := $AnimationPlayer
@onready var characterSprite := $CharacterSprite

enum State { IDLE, WALK }
var state := State.IDLE

func _process(_delta: float) -> void:
	handleMovement()
	handleInput()
	handleAnimation()
	flipCharacter()
	move_and_slide()

func handleMovement() -> void:
	if velocity.length() == 0:
		state = State.IDLE
	else:
		state = State.WALK

func handleInput() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction*speed
	
func handleAnimation() -> void:
	if state == State.IDLE:
		animatedSprite.play("idle")
	elif  state == State.WALK:
		animatedSprite.play("walk")

func flipCharacter() -> void:
	if velocity.x > 0:
		characterSprite.flip_h = false
	elif velocity.x < 0:
		characterSprite.flip_h = true
