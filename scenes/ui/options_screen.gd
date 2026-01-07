class_name OptionsScreen
extends Control

signal exit

@onready var musicVolume : RangePicker = $Background/MarginContainer/VBoxContainer/MusicVolume
@onready var soundVolume : RangePicker = $Background/MarginContainer/VBoxContainer/SoundVolume
@onready var shakeToggle : TogglePicker = $Background/MarginContainer/VBoxContainer/ShakeToggle
@onready var returnButton : LabelPicker = $Background/MarginContainer/VBoxContainer/ReturnButton
@onready var activables := [musicVolume, soundVolume, shakeToggle, returnButton]

var currentSelectedIndex := 0

func _ready() -> void:
	musicVolume.setValue(OptionsManager.musicVolume)
	soundVolume.setValue(OptionsManager.sfxVolume)
	shakeToggle.setValue(OptionsManager.isScreenshakeEnabled as int)
	musicVolume.valueChanged.connect(onMusicVolumeChanged.bind())
	soundVolume.valueChanged.connect(onSoundVolumeChanged.bind())
	shakeToggle.valueChanged.connect(onShakeValueChanged.bind())
	returnButton.press.connect(onReturnPressed.bind())
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
		SoundPlayer.play(SoundManager.Sound.CLICK)
	if Input.is_action_just_pressed("up"):
		currentSelectedIndex = clamp(currentSelectedIndex - 1, 0, activables.size() - 1)
		refresh()
		SoundPlayer.play(SoundManager.Sound.CLICK)

func onMusicVolumeChanged(value: int) -> void:
	OptionsManager.handleMusicVolume(value)

func onSoundVolumeChanged(value: int) -> void:
	OptionsManager.handleSFXVolume(value)
	SoundPlayer.play(SoundManager.Sound.HIT1)

func onShakeValueChanged(value: int) -> void:
	OptionsManager.handleShakeToggle(value == 1)

func onReturnPressed() -> void:
	exit.emit()
