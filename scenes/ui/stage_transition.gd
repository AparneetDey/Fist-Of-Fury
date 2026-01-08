class_name StageTransition
extends Control

@onready var animationPlayer := $AnimationPlayer

func startTransition() -> void:
	animationPlayer.play("startTransition")

func endTransition() -> void:
	animationPlayer.play("endTransition")

func onCompleteStartTransition() -> void:
	animationPlayer.play("interim")
	StageManager.stageInterim.emit()

func onCompleteEndTransition() -> void:
	animationPlayer.play("idle")
