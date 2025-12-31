extends Node2D

const SHOTPREFAB := preload("res://scenes/props/shot.tscn")
const PREFABMAP := {
	Collectible.Type.KNIFE: preload("res://scenes/props/knife.tscn"),
	Collectible.Type.GUN: preload("res://scenes/props/gun.tscn")
}

func _ready() -> void:
	EntityManager.spawnCollectible.connect(onCollectibleSpawn.bind())
	EntityManager.spawnShot.connect(onShotSpawn.bind())

func onCollectibleSpawn(type: Collectible.Type, initialState: Collectible.State, collectibleGlobalPosition: Vector2, collectibleDirection: Vector2, collectibleHeight: float) -> void:
	var collectible : Collectible = PREFABMAP[type].instantiate()
	collectible.state = initialState
	collectible.global_position = collectibleGlobalPosition
	collectible.direction = collectibleDirection
	collectible.height = collectibleHeight
	call_deferred("add_child", collectible)

func onShotSpawn(gunRootPosition: Vector2, distanceTravelled: float, height: float) -> void:
	var shot := SHOTPREFAB.instantiate()
	add_child(shot)
	shot.position = gunRootPosition
	shot.initialize(distanceTravelled, height)
