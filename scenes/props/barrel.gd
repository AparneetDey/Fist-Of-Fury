extends StaticBody2D

@onready var damageReceiver := $DamageReceiver
@onready var sprite := $Sprite2D
@onready var timer := $Timer

@export var knockbackIntensity : float

enum State { IDLE, DESTROYED }

var state := State.IDLE
var velocity := Vector2.ZERO
var height := 0.0
var heightSpeed := 0.0

const GRAVITY := 600

func _ready() -> void:
	damageReceiver.damageReceived.connect(onReceiveDamage.bind())
	
func _process(delta: float) -> void:
	position += velocity * delta
	sprite.position = Vector2.UP * height
	handleAirTime(delta)
	
func onReceiveDamage(_damage : int, direction : Vector2) -> void:
	if state == State.IDLE:
		state = State.DESTROYED
		sprite.frame = 1
		heightSpeed = knockbackIntensity * 2
		velocity = direction * knockbackIntensity
		
		
func handleAirTime(delta : float) -> void:
	if state == State.DESTROYED:
		height += heightSpeed * delta
		modulate.a -= delta
		if height < 0:
			velocity = Vector2.ZERO
			height = 0
			queue_free()
		else:
			heightSpeed -= GRAVITY * delta
