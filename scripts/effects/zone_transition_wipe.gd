extends CanvasLayer

# zone_transition_wipe.gd - Zone transition wipe effect

signal wipe_completed()

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_wipe(direction: String = "left"):
	animation_player.play("wipe_" + direction)
	await animation_player.animation_finished
	emit_signal("wipe_completed")

func set_color(col: Color):
	color_rect.color = col
