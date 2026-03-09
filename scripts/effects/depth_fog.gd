extends CanvasLayer

# depth_fog.gd - Depth fog overlay

@onready var color_rect: ColorRect = $ColorRect

var current_depth: int = 1

func _process(delta):
	update_fog()

func update_fog():
	var target_alpha = 0.0
	
	match current_depth:
		1: target_alpha = 0.1
		2: target_alpha = 0.2
		3: target_alpha = 0.35
		4: target_alpha = 0.5
	
	color_rect.color.a = lerp(color_rect.color.a, target_alpha, 0.1)

func set_depth(depth: int):
	current_depth = depth
