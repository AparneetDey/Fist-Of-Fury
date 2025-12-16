class_name DamageReceiver
extends Area2D

enum HitType {NORMAL, KNOCKDOWN, POWER}

signal damageReceived(damage : int, direction: Vector2, hitType: HitType)
