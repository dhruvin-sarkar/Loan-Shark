extends Node2D

# leviathan_shake.gd - Leviathan screen shake effect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var camera: Camera2D = null

func play_shake(intensity: float = 10.0, duration: float = 1.0):
	if camera:
		var original_offset = camera.offset
		var elapsed = 0.0
		
		while elapsed < duration:
			camera.offset = original_offset + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
			elapsed += get_process_delta_time()
			await get_tree().process_frame
		
		camera.offset = original_offset

func set_camera(cam: Camera2D):
	camera = cam
