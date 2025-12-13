extends StaticBody2D

@onready var damageReceiver := $DamageReceiver

func _ready() -> void:
	damageReceiver.damageReceived.connect(onReceiveDamage.bind())
	
func onReceiveDamage(damage : int) -> void:
	print(damage)
	queue_free()
