class_name Camera
extends Camera2D

@export var DurationShake : int
@export var ShakeIntensity : int

var isShaking := false
var timeStartShaking := Time.get_ticks_msec()

func _init() -> void:
	DamageManager.heavyBlowReceived.connect(onHeavyBlowRecieved.bind())

func _process(_delta: float) -> void:
	if isShaking and (Time.get_ticks_msec() - timeStartShaking) < DurationShake:
		offset = Vector2(randi_range(-ShakeIntensity, ShakeIntensity), randi_range(-ShakeIntensity, ShakeIntensity))
	else:
		offset = Vector2.ZERO
		isShaking = false

func onHeavyBlowRecieved() -> void:
	isShaking = true
	timeStartShaking = Time.get_ticks_msec()
