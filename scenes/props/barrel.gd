extends StaticBody2D

@export var contentType : Collectible.Type
@export var knockbackIntensity : float

@onready var damageReceiver := $DamageReceiver
@onready var sprite := $Sprite2D

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
	
func onReceiveDamage(_damage : int, direction : Vector2, _hitType : DamageReceiver.HitType) -> void:
	if state == State.IDLE:
		state = State.DESTROYED
		sprite.frame = 1
		heightSpeed = knockbackIntensity * 2
		velocity = direction * knockbackIntensity
		EntityManager.spawnCollectible.emit(contentType, Collectible.State.FALL, global_position, Vector2.ZERO, 0.0, false)

		
func handleAirTime(delta : float) -> void:
	if state == State.DESTROYED:
		modulate.a -= delta
		height += heightSpeed * delta
		if height < 0:
			velocity = Vector2.ZERO
			height = 0
			queue_free()
		else:
			heightSpeed -= GRAVITY * delta
