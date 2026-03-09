extends Node2D

# fishing_line.gd - Fishing line controller

signal line_cast(target_position: Vector2)
signal line_retracted()

var is_cast: bool = false
var hook_position: Vector2 = Vector2.ZERO

@onready var line_2d: Line2D = $Line2D
@onready var hook_point: Marker2D = $HookPoint

func _process(delta):
	if is_cast:
		_update_line()

func _update_line():
	line_2d.set_point_position(1, hook_point.position)

func cast_line(target: Vector2):
	is_cast = true
	hook_position = target
	hook_point.position = to_local(target)
	emit_signal("line_cast", target)

func retract_line():
	is_cast = false
	hook_position = Vector2.ZERO
	hook_point.position = Vector2(0, 100)
	emit_signal("line_retracted")

func get_hook_position() -> Vector2:
	return hook_point.global_position
