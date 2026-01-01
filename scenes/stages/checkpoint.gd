class_name Checkpoint
extends Node2D

@export var noSimultaneosEnemies : int

@onready var enemies := $Enemies
@onready var playerDetectionArea := $PlayerDetectionArea

var activeEnemyCounter := 0
var enemyData : Array[EnemyData] = []
var isActivated := false

func _ready() -> void:
	playerDetectionArea.body_entered.connect(onPlayerEnter.bind())
	EntityManager.deathEnemy.connect(onEnemyDeath.bind())
	for enemy : Character in enemies.get_children():
		enemyData.append(EnemyData.new(enemy.type, enemy.global_position))
		enemy.queue_free()
	print(enemyData.size())

func _process(_delta: float) -> void:
	if isActivated and canSpawnEnemies():
		var enemy = enemyData.pop_front()
		EntityManager.spawnEnemy.emit(enemy.type, enemy.global_position)
		activeEnemyCounter += 1

func canSpawnEnemies() -> bool:
	return enemyData.size() > 0 and activeEnemyCounter < noSimultaneosEnemies

func onPlayerEnter(_player : Player) -> void:
	if not isActivated:
		isActivated = true
		activeEnemyCounter = 0
		StageManager.checkpointStart.emit()

func onEnemyDeath() -> void:
	activeEnemyCounter -= 1
	if activeEnemyCounter == 0 and enemyData.size() == 0:
		StageManager.checkpointCompleted.emit()
		queue_free()
