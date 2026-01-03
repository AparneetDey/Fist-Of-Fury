class_name HealthBar
extends Control

@export var healthBarLength : int

@onready var whiteBorder := $WhiteBorder
@onready var contentBackground := $ContentBackground
@onready var healthGauge := $HealthGauge

func _ready() -> void:
	whiteBorder.scale.x = healthBarLength + 2
	contentBackground.scale.x = healthBarLength

func refresh(currentHealth : int, maxHealth : int):
	var healthPercentage = currentHealth / float(maxHealth)
	healthGauge.scale.x = healthPercentage * healthBarLength
