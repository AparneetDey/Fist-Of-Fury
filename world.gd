extends Node2D

@onready var camera := $Camera
@onready var player := $ActorsContainer/Player

func _process(_delta: float) -> void:
	if player and player.position.x > camera.position.x:
		camera.position.x = player.position.x
