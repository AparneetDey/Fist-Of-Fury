class_name DeathScreen
extends MarginContainer

@export var countdownStart : int

@onready var timer := $Timer
@onready var countdownLabel := $Border/Contents/Background/VBoxContainer/CountdownLabel

var currentCount := 0

func _ready() -> void:
	currentCount = countdownStart
	timer.timeout.connect(onTimeOut.bind())
	refresh()

func refresh() -> void:
	countdownLabel.text = str(currentCount)

func onTimeOut() -> void:
	if currentCount > 0:
		currentCount -= 1
		refresh()
	else:
		queue_free()
