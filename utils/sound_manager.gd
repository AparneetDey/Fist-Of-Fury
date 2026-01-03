class_name SoundManager
extends Node

@onready var sounds : Array[AudioStreamPlayer] = [$SFXClick, $SFXFood, $SFXGogogo, $SFXGrunt, $SFXGunShot, $SFXHit1, $SFXHit2, $SFXKnifeHit, $SFXSwoosh]

enum Sound {CLICK, FOOD, GOGOGO, GRUNT, GUNSHOT, HIT1, HIT2, KNIFEHIT, SWOOSH}

func play(sfx: Sound, tweakPitch: bool = false):
	var addedPitch := 0.0
	if tweakPitch:
		addedPitch += randf_range(-0.3, 0.3)
	sounds[sfx as int].pitch_scale = 1 + addedPitch
	sounds[sfx as int].play()
