class_name ScoreIndicator
extends Label

@export var DurationUpdateScore : float
@export var PointsPerLife : int

var displayedScore := 0
var realScore := 0
var priorScore := 0
var timeSinceUpdatingScore := Time.get_ticks_msec()

func _ready() -> void:
	displayedScore = 0
	DamageManager.onRevive.connect(onPlayerRevive.bind())
	refresh()

func _process(_delta: float) -> void:
	if realScore != priorScore:
		var progress = (Time.get_ticks_msec() - timeSinceUpdatingScore) / DurationUpdateScore
		if progress < 1:
			displayedScore = lerp(priorScore, realScore, progress)
		else:
			displayedScore = realScore
		refresh()

func refresh() -> void:
	text = str(displayedScore)

func updateScore(points: int) -> void:
	realScore += int((points * (points + 1)) / 2.0)
	startUpdate()

func onPlayerRevive() -> void:
	realScore = max(0, realScore - PointsPerLife)
	startUpdate()

func startUpdate() -> void:
	priorScore = displayedScore
	timeSinceUpdatingScore = Time.get_ticks_msec()
