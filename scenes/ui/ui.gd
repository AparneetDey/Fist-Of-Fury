extends CanvasLayer

const AVATARMAP := {
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png")
}

@export var DurationEnemyHealthVisible : int

@onready var playerHealthBar := $UIControls/PlayerHealthBar
@onready var enemyAvatar := $UIControls/EnemyAvatar
@onready var enemyHealthBar := $UIControls/EnemyHealthBar

var timeEnemyHealthVisible := Time.get_ticks_msec()

func _init() -> void:
	DamageManager.healthChange.connect(onHealthChange.bind())

func _ready() -> void:
	enemyAvatar.visible = false
	enemyHealthBar.visible = false

func _process(_delta: float) -> void:
	if enemyHealthBar.visible and (Time.get_ticks_msec() - timeEnemyHealthVisible) > DurationEnemyHealthVisible:
		enemyAvatar.visible = false
		enemyHealthBar.visible = false

func onHealthChange(characterType: Character.Type, currentHealth: int, maxHealth: int) -> void:
	if characterType == Character.Type.PLAYER:
		playerHealthBar.refresh(currentHealth, maxHealth)
	else:
		enemyAvatar.texture = AVATARMAP[characterType]
		enemyHealthBar.refresh(currentHealth, maxHealth)
		enemyAvatar.visible = true
		enemyHealthBar.visible = true
		timeEnemyHealthVisible = Time.get_ticks_msec()
