extends Node

signal spawnCollectible(
	type: Collectible.Type, 
	initialState: Collectible.State, 
	collectibleGlobalPosition: Vector2, 
	collectibleDirection: Vector2, 
	collectibleHeight: float, 
	autoDestroy: bool
)
signal  spawnShot(gunRootPosition: Vector2, distanceTravelled: float, height: float)

signal spawnEnemy(enemyData: EnemyData)
signal deathEnemy

signal orphanActor(orphan : Node2D)
