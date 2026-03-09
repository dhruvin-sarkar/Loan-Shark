extends Node

# SceneManager.gd - Manages scene transitions and animations

signal scene_changed(scene_name: String)
signal transition_started()
signal transition_completed()

var current_scene: String = ""
var transition_layer: CanvasLayer = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_scene(scene_path: String, transition_type: String = "fade"):
	emit_signal("transition_started")
	
	# Wait for transition animation
	await _play_transition_out(transition_type)
	
	get_tree().change_scene_to_file(scene_path)
	current_scene = scene_path
	
	# Wait for scene to load
	await get_tree().tree_changed
	
	await _play_transition_in(transition_type)
	emit_signal("transition_completed")
	emit_signal("scene_changed", scene_path)

func reload_scene():
	if current_scene:
		change_scene(current_scene, "fade")

func _play_transition_out(transition_type: String) -> void:
	# Placeholder for transition animation
	await get_tree().create_timer(0.5).timeout

func _play_transition_in(transition_type: String) -> void:
	# Placeholder for transition animation
	await get_tree().create_timer(0.5).timeout

func get_current_scene_name() -> String:
	var parts = current_scene.split("/")
	if parts.size() > 0:
		return parts[-1].replace(".tscn", "")
	return ""

func is_in_ocean() -> bool:
	return current_scene.contains("ocean")

func is_in_world() -> bool:
	return current_scene.contains("world")

# === GDD REQUIRED METHODS (Section 21) ===

func show_win_screen() -> void:
	change_scene("res://scenes/ui/WinScreen.tscn", "fade_black")

func show_game_over(reason: String) -> void:
	# Store reason for GameOverScreen to display appropriate message
	# Note: This would typically be passed via a global or autoload
	change_scene("res://scenes/ui/GameOverScreen.tscn", "fade_black")

func show_day_end_summary() -> void:
	change_scene("res://scenes/ui/DayEndSummary.tscn", "fade_black")

func start_minigame(type: String) -> void:
	# Minigames are CanvasLayer scenes added as children of Main
	# NOT loaded into WorldContainer per GDD Section 30 Note 2
	var minigame_scene_path = "res://scenes/minigames/" + type.capitalize() + "Minigame.tscn"
	if ResourceLoader.exists(minigame_scene_path):
		var minigame_scene = load(minigame_scene_path)
		var minigame_instance = minigame_scene.instantiate()
		# Add to Main scene (root)
		get_tree().root.get_child(0).add_child(minigame_instance)

func end_minigame() -> void:
	# Remove active minigame from Main scene
	var root = get_tree().root.get_child(0)
	for child in root.get_children():
		if child is CanvasLayer and (child.name.contains("Minigame") or child.name.contains("minigame")):
			child.queue_free()
			break
