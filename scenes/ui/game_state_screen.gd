class_name GameStateScreen
extends Control

@onready var scoreIndicator : ScoreIndicator = $Background/MarginContainer/Contents/ScoreSection/ScoreIndicator
@onready var timer : Timer = $Timer

var finalScore := 0
var canRestart := false

func _ready() -> void:
	timer.timeout.connect(onTimerTimeout.bind())

func _process(_delta: float) -> void:
	if canRestart and (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump")):
		StageManager.gameRestart.emit()

func setScore(value: int) -> void:
	finalScore = value
	canRestart = true

func onTimerTimeout() -> void:
	scoreIndicator.addScore(finalScore)
