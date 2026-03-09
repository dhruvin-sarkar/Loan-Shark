extends CanvasLayer

# transition_layer.gd - Scene transition controller

signal transition_finished()

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_transitioning: bool = false

func fade_in(duration: float = 0.5):
	is_transitioning = true
	animation_player.play("fade_in")
	await animation_player.animation_finished
	is_transitioning = false
	emit_signal("transition_finished")

func fade_out(duration: float = 0.5):
	is_transitioning = true
	animation_player.play("fade_out")
	await animation_player.animation_finished
	is_transitioning = false
	emit_signal("transition_finished")

func wipe_left(duration: float = 0.5):
	is_transitioning = true
	animation_player.play("wipe_left")
	await animation_player.animation_finished
	is_transitioning = false
	emit_signal("transition_finished")
