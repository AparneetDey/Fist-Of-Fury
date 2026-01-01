class_name Checkpoint
extends Node2D

@onready var enemies := $Enemies
@onready var playerDetectionArea := $PlayerDetectionArea

var enemyData : Array[EnemyData] = []
var isActivated := false

func _ready() -> void:
	playerDetectionArea.body_entered.connect(onPlayerEnter.bind())
	for enemy : Character in enemies.get_children():
		enemyData.append(EnemyData.new(enemy.type, enemy.global_position))
		enemy.queue_free()

func _process(_delta: float) -> void:
	if isActivated and enemyData.size() > 0:
		var enemy = enemyData.pop_front()
		EntityManager.spawnEnemy.emit(enemy.type, enemy.global_position)

func onPlayerEnter(_player : Player) -> void:
	isActivated = true
