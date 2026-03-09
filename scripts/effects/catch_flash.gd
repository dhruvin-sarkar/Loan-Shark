extends CanvasLayer

# catch_flash.gd - Catch flash effect

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_flash():
	animation_player.play("flash")
	await animation_player.animation_finished
