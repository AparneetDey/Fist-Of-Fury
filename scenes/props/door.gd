class_name Door
extends Node2D

signal doorOpen

@export var DurationOpen : float
@export var Enemies : Array[BasicEnemy]

@onready var doorSprite := $DoorSprite

enum State { CLOSED, OPENING, OPENED}

var doorHeight := 0.0
var state := State.CLOSED
var timeSinceOpening := Time.get_ticks_msec()

func _ready() -> void:
	doorHeight = doorSprite.texture.get_height()

func _process(_delta: float) -> void:
	if state == State.OPENING:
		if (Time.get_ticks_msec() - timeSinceOpening) > DurationOpen:
			state = State.OPENED
			doorSprite.position = Vector2.UP * doorHeight
			doorOpen.emit()
		else:
			var progress := (Time.get_ticks_msec() - timeSinceOpening) / DurationOpen
			doorSprite.position = lerp(Vector2.ZERO, Vector2.UP * doorHeight, progress)

func open() -> void:
	if state == State.CLOSED:
		state = State.OPENING
		timeSinceOpening = Time.get_ticks_msec()
