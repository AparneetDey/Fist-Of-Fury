class_name BasicEnemy
extends Character

@export var player : Player

var playerSlot : EnemySlot = null

func handleInput() -> void:
	if player != null and canMove():
		
		if playerSlot == null:
			playerSlot = player.reserveSlot(self)
			
		if playerSlot != null:
			var direction := (playerSlot.global_position - global_position).normalized()
			if (playerSlot.global_position - global_position).length() < 1:
				velocity = Vector2.ZERO
			else:
				velocity = direction*Speed

func onReceiveDamage(damage : int, direction : Vector2, hitType : DamageReceiver.HitType) -> void:
	super.onReceiveDamage(damage, direction, hitType)
	if currentHealth <= 0:
		player.freeSlot(self)
