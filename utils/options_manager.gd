extends Node

var musicVolume := 3
var sfxVolume := 5
var isScreenshakeEnabled := true

func handleMusicVolume(value: int) -> void:
	musicVolume = value
	AudioServer.set_bus_volume_db(1, linear_to_db(value / 10.0))

func handleSFXVolume(value: int) -> void:
	sfxVolume = value
	AudioServer.set_bus_volume_db(2, linear_to_db(value / 10.0))

func handleShakeToggle(value: int) -> void:
	isScreenshakeEnabled = value
