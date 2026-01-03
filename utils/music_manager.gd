class_name MusicManager
extends Node

const MUSIC_MAP := {
	Music.INTRO: preload("res://assets/music/intro.mp3"),
	Music.MENU: preload("res://assets/music/menu.mp3"),
	Music.STAGE01: preload("res://assets/music/stage-01.mp3"),
	Music.STAGE02: preload("res://assets/music/stage-02.mp3"),
}

@onready var MusicStreamPlayer := $MusicStreamPlayer

enum Music { INTRO, MENU, STAGE01, STAGE02 }

var audioStream : AudioStream = null

func _process(_delta: float) -> void:
	if audioStream != null:
		MusicStreamPlayer.stream = audioStream
		MusicStreamPlayer.play()

func play(music: Music):
	if MusicStreamPlayer.is_node_ready():
		MusicStreamPlayer.stream = MUSIC_MAP[music]
		MusicStreamPlayer.play()
	else:
		audioStream = MUSIC_MAP[music]
