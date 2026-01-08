extends CanvasLayer

const AVATARMAP := {
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png")
}
const OPTIONS_SCREEN_PREFAB := preload("res://scenes/ui/options_screen.tscn")

@export var DurationEnemyHealthVisible : int

@onready var playerHealthBar := $UIControls/PlayerHealthBar
@onready var enemyAvatar := $UIControls/EnemyAvatar
@onready var enemyHealthBar := $UIControls/EnemyHealthBar
@onready var comboIndicator := $UIControls/ComboIndicator
@onready var scoreIndicator := $UIControls/ScoreIndicator
@onready var goIndicator := $UIControls/GoIndicator

var timeEnemyHealthVisible := Time.get_ticks_msec()
var optionsScreen : Control = null

func _init() -> void:
	DamageManager.healthChange.connect(onHealthChange.bind())
	StageManager.checkpointCompleted.connect(onCheckpointCompleted.bind())

func _ready() -> void:
	enemyAvatar.visible = false
	enemyHealthBar.visible = false
	comboIndicator.comboReset.connect(onComboReset.bind())

func _process(_delta: float) -> void:
	if enemyHealthBar.visible and (Time.get_ticks_msec() - timeEnemyHealthVisible) > DurationEnemyHealthVisible:
		enemyAvatar.visible = false
		enemyHealthBar.visible = false
	handleInput()

func onHealthChange(characterType: Character.Type, currentHealth: int, maxHealth: int) -> void:
	if characterType == Character.Type.PLAYER:
		playerHealthBar.refresh(currentHealth, maxHealth)
	else:
		enemyAvatar.texture = AVATARMAP[characterType]
		enemyHealthBar.refresh(currentHealth, maxHealth)
		enemyAvatar.visible = true
		enemyHealthBar.visible = true
		timeEnemyHealthVisible = Time.get_ticks_msec()

func handleInput() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if optionsScreen == null:
			optionsScreen = OPTIONS_SCREEN_PREFAB.instantiate()
			add_child(optionsScreen)
			optionsScreen.exit.connect(unpause)
			get_tree().paused = true
		else:
			unpause()

func unpause() -> void:
	optionsScreen.queue_free()
	get_tree().paused = false

func onComboReset(points: int) -> void:
	scoreIndicator.updateScore(points)

func onCheckpointCompleted() -> void:
	goIndicator.startFlickering()
