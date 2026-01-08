class_name GameOverScreen
extends Control

@onready var scoreIndicator : ScoreIndicator = $Background/MarginContainer/Contents/ScoreSection/ScoreIndicator
@onready var timer : Timer = $Timer

var finalScore := 0

func _ready() -> void:
	timer.timeout.connect(onTimerTimeout.bind())

func setScore(value: int) -> void:
	finalScore = value

func onTimerTimeout() -> void:
	scoreIndicator.addScore(finalScore)
