extends CanvasLayer

# shark_warning_vignette.gd - Shark warning vignette effect

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_warning: bool = false

func start_warning():
	is_warning = true
	animation_player.play("pulse")

func stop_warning():
	is_warning = false
	animation_player.stop()
	color_rect.color.a = 0

func _process(delta):
	if is_warning:
		# Pulse effect
		pass
