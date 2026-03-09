extends CanvasLayer

# day_night_overlay.gd - Day/night overlay effect

@onready var color_rect: ColorRect = $ColorRect

func _process(delta):
	update_overlay()

func update_overlay():
	var hour = DayNightCycle.current_hour
	var target_color = Color(0, 0, 0.1, 0)
	
	if hour >= 20 or hour < 6:
		# Night
		target_color = Color(0, 0, 0.2, 0.4)
	elif hour >= 18:
		# Evening
		target_color = Color(0.1, 0.05, 0.1, 0.2)
	elif hour >= 6 and hour < 8:
		# Dawn
		target_color = Color(0.05, 0.02, 0.05, 0.1)
	
	color_rect.color = lerp(color_rect.color, target_color, 0.05)
