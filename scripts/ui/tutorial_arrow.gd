extends Control

# tutorial_arrow.gd - Tutorial arrow indicator

@onready var arrow_sprite: Sprite2D = $ArrowSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target_position: Vector2 = Vector2.ZERO

func _ready():
	animation_player.play("bounce")

func point_to(position: Vector2):
	target_position = position
	_update_position()

func _update_position():
	global_position = target_position + Vector2(0, -50)

func hide_arrow():
	hide()

func show_arrow():
	show()
