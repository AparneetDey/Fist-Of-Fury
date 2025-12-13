extends CharacterBody2D

@export var health : int
@export var damage : int
@export var speed : float

func _process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	position += delta*direction*speed
