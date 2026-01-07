class_name RangePicker
extends ActivableControl

const TICK_ON := preload("res://assets/art/ui/ui-tick-on.png")
const TICK_OFF := preload("res://assets/art/ui/ui-tick-off.png")

@onready var ticksContainer := $TicksContainer

func _process(_delta: float) -> void:
	if isActive:
		handleInput()

func refresh() -> void:
	var ticks : Array = ticksContainer.get_children()
	for i in range(0, currentValue):
		ticks[i].texture = TICK_ON
	for i in range(currentValue, ticks.size()):
		ticks[i].texture = TICK_OFF

func handleInput() -> void:
	if Input.is_action_just_pressed("left"):
		setValue(currentValue - 1)
	if Input.is_action_just_pressed("right"):
		setValue(currentValue + 1)
