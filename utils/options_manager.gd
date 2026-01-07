extends Node

var musicVolume := 3
var sfxVolume := 5
var isScreenshakeEnabled := true

func handleMusicVolume(value: int) -> void:
	musicVolume = value

func handleSFXVolume(value: int) -> void:
	sfxVolume = value

func handleShakeToggle(value: int) -> void:
	isScreenshakeEnabled = value
