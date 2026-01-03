extends CanvasLayer

@onready var playerHealthBar := $UIControls/PlayerHealthBar

func _ready() -> void:
	DamageManager.healthChange.connect(onHealthChange.bind())

func onHealthChange(characterType: Character.Type, currentHealth: int, maxHealth: int) -> void:
	if characterType == Character.Type.PLAYER:
		playerHealthBar.refresh(currentHealth, maxHealth)
