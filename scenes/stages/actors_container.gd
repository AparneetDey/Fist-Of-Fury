extends Node2D

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

func _ready() -> void:
	EntityManager.spawnCollectible.connect(onCollectibleSpawn.bind())
	EntityManager.spawnShot.connect(onShotSpawn.bind())
	EntityManager.spawnEnemy.connect(onEnemySpawn.bind())

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

func onEnemySpawn(enemyType: Character.Type, enemyPosition: Vector2) -> void:
	var enemy : Character = ENEMYMAP[enemyType].instantiate()
	enemy.global_position = enemyPosition
	enemy.player = player
	add_child(enemy)
