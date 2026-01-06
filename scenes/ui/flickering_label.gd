class_name FlickeringLabel
extends TextureRect

@export var DurationFlicker : int
@export var TotalFlickers : int

var flickersLeft := 0
var isFlickering := false
var image : Texture2D = null
var timeStartLastFlicker := Time.get_ticks_msec()

func _ready() -> void:
	image = texture
	texture = null

func _process(_delta: float) -> void:
	if isFlickering and (Time.get_ticks_msec() - timeStartLastFlicker > DurationFlicker):
		if texture == null:
			if flickersLeft == 0:
				isFlickering = false
			else:
				flickersLeft -= 1
				texture = image
		else:
			texture = null
		timeStartLastFlicker = Time.get_ticks_msec()

func startFlickering() -> void:
	isFlickering = true
	flickersLeft = TotalFlickers
	timeStartLastFlicker = Time.get_ticks_msec()
	SoundPlayer.play(SoundManager.Sound.GOGOGO)
