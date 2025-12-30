class_name Shot
extends Line2D

@export var DurationShotAcrossScreen : float

var durationShot := 0.0
var shotDistance := 0.0
var height := 0.0
var timeStart := Time.get_ticks_msec()

func initialize(distance: float, gunHeight: float) -> void:
	shotDistance = distance
	height = gunHeight
	add_point(Vector2(0, -height), 0)
	add_point(Vector2(distance, -height), 1)
	durationShot = abs(shotDistance) * DurationShotAcrossScreen / get_viewport_rect().size.x

func _process(_delta: float) -> void:
	var elapsed := Time.get_ticks_msec() - timeStart
	var progress := elapsed / durationShot
	var newX : float = lerp(0.0, shotDistance, progress)
	set_point_position(0, Vector2(newX, -height))
	if progress >= 1:
		queue_free()
