class_name TogglePicker
extends ActivableControl

@onready var valueLabel := $ValueLabel

func _process(_delta: float) -> void:
	if isActive and handleInput():
		setValue(0 if currentValue == 1 else 1)

func refresh() -> void:
	valueLabel.text = "ON" if currentValue == 1 else "OFF"

func handleInput() -> bool:
	var actions := ["left", "right", "jump", "attack"]
	for action in actions:
		if Input.is_action_just_pressed(action):
			return true
	return false
