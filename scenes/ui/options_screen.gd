class_name OptionsScreen
extends Control

@onready var musicVolume := $Background/MarginContainer/VBoxContainer/MusicVolume
@onready var soundVolume := $Background/MarginContainer/VBoxContainer/SoundVolume
@onready var shakeToggle := $Background/MarginContainer/VBoxContainer/ShakeToggle
@onready var returnButton := $Background/MarginContainer/VBoxContainer/ReturnButton
@onready var activables := [musicVolume, soundVolume, shakeToggle, returnButton]

var currentSelectedIndex := 0

func _ready() -> void:
	refresh()

func _process(_delta: float) -> void:
	handleInput()

func refresh() -> void:
	for i in range(0, activables.size()):
		activables[i].setActive(currentSelectedIndex == i)

func handleInput() -> void:
	if Input.is_action_just_pressed("down"):
		currentSelectedIndex = clamp(currentSelectedIndex + 1, 0, activables.size() - 1)
		refresh()
	if Input.is_action_just_pressed("up"):
		currentSelectedIndex = clamp(currentSelectedIndex - 1, 0, activables.size() - 1)
		refresh()
