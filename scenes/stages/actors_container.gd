extends Node2D

const SPARKPREFAB := preload("res://scenes/vfx/spark.tscn")
const SHOTPREFAB := preload("res://scenes/props/shot.tscn")
const PREFABMAP := {
	Collectible.Type.KNIFE: preload("res://scenes/props/knife.tscn"),
	Collectible.Type.GUN: preload("res://scenes/props/gun.tscn"),
	Collectible.Type.FOOD: preload("res://scenes/props/food.tscn")
}
const ENEMYMAP := {
	Character.Type.PUNK: preload("res://scenes/characters/basic_enemy.tscn"),
	Character.Type.GOON: preload("res://scenes/characters/goon_enemy.tscn"),
	Character.Type.THUG: preload("res://scenes/characters/thug_enemy.tscn"),
	Character.Type.BOUNCER: preload("res://scenes/characters/igor_boss.tscn")
}

@export var player : Player

var doors : Array[Door] = []

func _init() -> void:
	EntityManager.spawnCollectible.connect(onCollectibleSpawn.bind())
	EntityManager.spawnShot.connect(onShotSpawn.bind())
	EntityManager.spawnEnemy.connect(onEnemySpawn.bind())
	EntityManager.orphanActor.connect(onOrphanActor.bind())
	EntityManager.spawnSpark.connect(onSpawnSpark.bind())

func onCollectibleSpawn(type: Collectible.Type, initialState: Collectible.State, collectibleGlobalPosition: Vector2, collectibleDirection: Vector2, collectibleHeight: float, autoDestroy: bool) -> void:
	var collectible : Collectible = PREFABMAP[type].instantiate()
	collectible.state = initialState
	collectible.global_position = collectibleGlobalPosition
	collectible.direction = collectibleDirection
	collectible.height = collectibleHeight
	collectible.AutoDestroy = autoDestroy
	call_deferred("add_child", collectible)

func onShotSpawn(gunRootPosition: Vector2, distanceTravelled: float, height: float) -> void:
	var shot := SHOTPREFAB.instantiate()
	add_child(shot)
	shot.position = gunRootPosition
	shot.initialize(distanceTravelled, height)

func onEnemySpawn(enemyData: EnemyData) -> void:
	var enemy : Character = ENEMYMAP[enemyData.type].instantiate()
	enemy.global_position = enemyData.global_position
	enemy.height = enemyData.height
	enemy.state = enemyData.state
	enemy.player = player
	enemy.assignedDoorIndex = enemyData.doorIndex
	if enemyData.doorIndex > -1:
		enemy.handleAssignedDoor(doors[enemyData.doorIndex])
	add_child(enemy)

func onOrphanActor(orphan : Node2D) -> void:
	if orphan is Door:
		doors.append(orphan)
	orphan.reparent(self)

func onSpawnSpark(sparkPosition: Vector2) -> void:
	var spark = SPARKPREFAB.instantiate()
	spark.position = sparkPosition
	add_child(spark)
