class_name ComboIndicator
extends Label

@export var DurationComboTimeOut : int

var comboCounter := 0
var timeSinceComboTimeOut := Time.get_ticks_msec()

func _init() -> void:
	ComboManager.registerHit.connect(onAttackHit.bind())

func _ready() -> void:
	comboCounter = 0
	refresh()

func _process(_delta: float) -> void:
	if comboCounter > 0 and (Time.get_ticks_msec() - timeSinceComboTimeOut) > DurationComboTimeOut:
		comboCounter = 0	
		refresh()

func refresh() -> void:
	if comboCounter > 0:
		text = "x" + str(comboCounter)
	else:
		text = ""

func onAttackHit() -> void:
	comboCounter += 1
	timeSinceComboTimeOut = Time.get_ticks_msec()
	refresh()
