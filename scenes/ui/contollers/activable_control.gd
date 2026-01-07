class_name ActivableControl
extends HBoxContainer

@export var text : String
@export var defaultColor : Color
@export var activeColor : Color
@export var currentValue : int
@export var minValue : int
@export var maxValue : int

@onready var label := $Label

var isActive = false

func _ready() -> void:
	label.text = text.to_upper()
	setValue(currentValue)

func setActive(active: bool) -> void:
	isActive = active
	for control : Control in get_children():
		control.modulate = activeColor if isActive else defaultColor

func setValue(value: int) -> void:
	currentValue = clamp(value, minValue, maxValue)
	refresh()

func refresh() -> void:
	pass
