class_name DeathScreen
extends MarginContainer

signal  gameOver

@export var countdownStart : int

@onready var timer := $Timer
@onready var countdownLabel := $Border/Contents/Background/VBoxContainer/CountdownLabel

var currentCount := 0

func _ready() -> void:
	currentCount = countdownStart
	timer.timeout.connect(onTimeOut.bind())
	refresh()

func _process(_delta: float) -> void:
	if currentCount < countdownStart and (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump")):
		DamageManager.onRevive.emit()
		queue_free()

func refresh() -> void:
	countdownLabel.text = str(currentCount)

func onTimeOut() -> void:
	if currentCount > 0:
		currentCount -= 1
		refresh()
	else:
		gameOver.emit()
		queue_free()
