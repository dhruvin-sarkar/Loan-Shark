extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite

var movement_mode: String = "overworld"
var world_bounds: Rect2 = Rect2(32, 32, 1216, 656)
var _stunned: bool = false

func _physics_process(_delta: float) -> void:
	if _stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var input := Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	if movement_mode == "ocean":
		input.y = Input.get_axis("move_up", "move_down")
	var speed_x := 120.0 if movement_mode == "overworld" else 80.0
	var speed_y := 60.0 if movement_mode == "ocean" else 0.0
	velocity = Vector2(input.x * speed_x, input.y * speed_y)
	move_and_slide()
	global_position.x = clamp(global_position.x, world_bounds.position.x, world_bounds.position.x + world_bounds.size.x)
	global_position.y = clamp(global_position.y, world_bounds.position.y, world_bounds.position.y + world_bounds.size.y)
	_update_facing(input)

func set_world_bounds(bounds: Rect2) -> void:
	world_bounds = bounds

func set_movement_mode(mode: String) -> void:
	movement_mode = mode

func stun(duration: float) -> void:
	if _stunned:
		return
	_stunned = true
	await get_tree().create_timer(duration).timeout
	_stunned = false

func _update_facing(input: Vector2) -> void:
	if input.x < 0.0:
		sprite.flip_h = true
	elif input.x > 0.0:
		sprite.flip_h = false
