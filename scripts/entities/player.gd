extends CharacterBody2D

# player.gd - Player controller

signal player_moved(position: Vector2)
signal player_interacted(target: Node)

const SPEED = 200.0

var can_move: bool = true
var facing_direction: Vector2 = Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interaction_area: Area2D = $InteractionArea

func _physics_process(delta):
	if not can_move:
		return
	
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	
	if input_dir != Vector2.ZERO:
		facing_direction = input_dir.normalized()
		velocity = facing_direction * SPEED
		_update_animation()
	else:
		velocity = Vector2.ZERO
		_idle_animation()
	
	move_and_slide()
	emit_signal("player_moved", global_position)

func _input(event):
	if event.is_action_pressed("interact"):
		_try_interact()

func _update_animation():
	match facing_direction:
		Vector2.UP:
			sprite.play("walk_up")
		Vector2.DOWN:
			sprite.play("walk_down")
		Vector2.LEFT:
			sprite.play("walk_left")
		Vector2.RIGHT:
			sprite.play("walk_right")

func _idle_animation():
	match facing_direction:
		Vector2.UP:
			sprite.play("idle_up")
		Vector2.DOWN:
			sprite.play("idle_down")
		Vector2.LEFT:
			sprite.play("idle_left")
		Vector2.RIGHT:
			sprite.play("idle_right")

func _try_interact():
	var bodies = interaction_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("interactable"):
			emit_signal("player_interacted", body)
			return

func set_can_move(value: bool):
	can_move = value
	if not can_move:
		velocity = Vector2.ZERO
