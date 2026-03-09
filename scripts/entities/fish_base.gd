extends Area2D

# fish_base.gd - Base fish behavior

signal fish_caught()
signal fish_escaped()

export var fish_data: Resource
export var swim_speed: float = 50.0

var is_caught: bool = false
var movement_direction: Vector2 = Vector2.RIGHT

@onready var sprite: Sprite2D = $Sprite2D
@onready var movement_timer: Timer = $MovementTimer

func _ready():
	movement_timer.timeout.connect(_change_direction)
	movement_timer.start()

func _process(delta):
	if not is_caught:
		_swim(delta)

func _swim(delta):
	position += movement_direction * swim_speed * delta

func _change_direction():
	movement_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func get_caught(hook: Node2D):
	is_caught = true
	emit_signal("fish_caught")
	# Attach to hook
	reparent(hook)
	position = Vector2.ZERO

func escape():
	is_caught = false
	emit_signal("fish_escaped")
	_change_direction()

func get_value() -> int:
	if fish_data:
		return fish_data.base_value
	return 10

func get_name() -> String:
	if fish_data:
		return fish_data.name
	return "Unknown Fish"
