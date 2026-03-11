extends CanvasLayer

@onready var arrow: Control = $Arrow

var _base_position: Vector2 = Vector2.ZERO
var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	if arrow:
		arrow.position = _base_position + Vector2(0.0, sin(_time * 5.0) * 10.0)

func point_to(target_position: Vector2) -> void:
	_base_position = target_position + Vector2(0.0, -72.0)
	if arrow:
		arrow.position = _base_position
	visible = true
