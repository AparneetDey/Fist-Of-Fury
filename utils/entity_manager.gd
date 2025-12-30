extends Node

signal spawnCollectible(type: Collectible.Type, initialState: Collectible.State, collectibleGlobalPosition: Vector2, collectibleDirection: Vector2, collectibleHeight: float)

signal  spawnShot(gunRootPosition: Vector2, distanceTravelled: float, height: float)
