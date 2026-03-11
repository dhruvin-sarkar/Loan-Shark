extends Node

@export var lifetime: float = 2.0

func _ready() -> void:
	if lifetime <= 0.0:
		return
	await get_tree().create_timer(lifetime).timeout
	queue_free()
