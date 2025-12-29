class_name Collectible
extends Area2D

const GRAVITY := 600.0

@export var KnockdownIntensity : float
@export var Speed : float
@export var type : Type

@onready var animationPlayer := $AnimationPlayer
@onready var collectibleSprite := $CollectibleSprite

enum State {FALL, GROUNDED, FLY}
enum Type {KNIFE, GUN, FOOD}

var animMaps := {
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.FLY: "fly",
}
var state = State.FALL
var height := 0.0
var heightSpeed := 0.0
var direction := Vector2.ZERO
var velocity := Vector2.ZERO

func _ready() -> void:
	heightSpeed = KnockdownIntensity
	if state == State.FLY:
		velocity = direction * Speed

func _process(delta: float) -> void:
	handleFall(delta)
	handleAnimations()
	collectibleSprite.position = Vector2.UP * height
	collectibleSprite.flip_h = velocity < Vector2.ZERO
	position += velocity * delta

func handleAnimations() -> void:
	if animationPlayer.has_animation(animMaps[state]):
		animationPlayer.play(animMaps[state])

func handleFall(delta: float) -> void:
	if state == State.FALL:
		height += heightSpeed * delta
		if height < 0:
			height = 0
			state = State.GROUNDED
		else:
			heightSpeed -= GRAVITY * delta
