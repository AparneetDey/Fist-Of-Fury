extends CanvasLayer

const AVATARMAP := {
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png")
}
const OPTIONS_SCREEN_PREFAB := preload("res://scenes/ui/options_screen.tscn")
const DEATH_SCREEN_PREFAB := preload("res://scenes/ui/death_screen.tscn")
const GAME_OVER_PREFAB := preload("res://scenes/ui/game_over_screen.tscn")
const GAME_COMPLETE_PREFAB := preload("res://scenes/ui/game_complete_screen.tscn")

@export var DurationEnemyHealthVisible : int

@onready var playerHealthBar : HealthBar = $UIControls/PlayerHealthBar
@onready var enemyAvatar := $UIControls/EnemyAvatar
@onready var enemyHealthBar : HealthBar = $UIControls/EnemyHealthBar
@onready var comboIndicator : ComboIndicator = $UIControls/ComboIndicator
@onready var scoreIndicator : ScoreIndicator = $UIControls/ScoreIndicator
@onready var goIndicator : FlickeringLabel = $UIControls/GoIndicator
@onready var stageTransition : StageTransition = $UIControls/StageTransition

var timeEnemyHealthVisible := Time.get_ticks_msec()
var optionsScreen : OptionsScreen = null
var deathScreen : DeathScreen = null
var gameOverScreen : GameStateScreen = null
var gameCompleteScreen : GameStateScreen = null

func _init() -> void:
	DamageManager.healthChange.connect(onHealthChange.bind())
	StageManager.checkpointCompleted.connect(onCheckpointCompleted.bind())
	StageManager.stageCompleted.connect(onStageCompleted.bind())
	StageManager.gameComplete.connect(onGameComplete.bind())
	StageManager.gameRestart.connect(onGameRestart.bind())

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
		if currentHealth == 0 and deathScreen == null:
			deathScreen = DEATH_SCREEN_PREFAB.instantiate()
			add_child(deathScreen)
			deathScreen.gameOver.connect(onGameOver.bind())
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

func onGameOver() -> void:
	if gameOverScreen == null:
		gameOverScreen = GAME_OVER_PREFAB.instantiate()
		add_child(gameOverScreen)
		gameOverScreen.setScore(scoreIndicator.realScore)

func onGameComplete() -> void:
	if gameCompleteScreen == null:
		gameCompleteScreen = GAME_COMPLETE_PREFAB.instantiate()
		add_child(gameCompleteScreen)
		gameCompleteScreen.setScore(scoreIndicator.realScore)

func onGameRestart() -> void:
	if gameOverScreen != null:
		gameOverScreen.queue_free()
	if gameCompleteScreen != null:
		gameCompleteScreen.queue_free()
	if optionsScreen != null:
		unpause()

func onComboReset(points: int) -> void:
	scoreIndicator.updateScore(points)

func onCheckpointCompleted(_checkpoint: Checkpoint) -> void:
	goIndicator.startFlickering()

func onStageCompleted() -> void:
	stageTransition.startTransition()
