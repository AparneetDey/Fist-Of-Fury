extends Node2D

var prefabMap := {
	Collectible.Type.KNIFE: preload("res://scenes/props/knife.tscn")
}

func _ready() -> void:
	EntityManager.spawnCollectible.connect(onCollectibleSpawn.bind())

func onCollectibleSpawn(type: Collectible.Type, initialState: Collectible.State, collectibleGlobalPosition: Vector2, collectibleDirection: Vector2, collectibleHeight: float) -> void:
	var collectible : Collectible = prefabMap[type].instantiate()
	collectible.state = initialState
	collectible.global_position = collectibleGlobalPosition
	collectible.direction = collectibleDirection
	collectible.height = collectibleHeight
	add_child(collectible)
