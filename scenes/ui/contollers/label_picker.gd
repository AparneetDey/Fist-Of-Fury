class_name LabelPicker
extends ActivableControl

signal press

func _process(_delta: float) -> void:
	if isActive and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack")):
		press.emit()
