extends Node
class_name SceneManager

const TRANSITION_FADE_BLACK := "fade_black"
const TRANSITION_SLIDE_RIGHT := "slide_right"
const TRANSITION_INSTANT := "instant"

const WORLD_SCENES := {
	"town": "res://scenes/world/Town.tscn",
	"beach": "res://scenes/world/Beach.tscn",
	"dock": "res://scenes/world/Dock.tscn",
	"ocean": "res://scenes/world/ocean/Ocean.tscn"
}

const MINIGAME_SCENES := {
	"cast": "res://scenes/minigames/CastMinigame.tscn",
	"reel": "res://scenes/minigames/ReelMinigame.tscn",
	"catch": "res://scenes/minigames/CatchMinigame.tscn",
	"filet": "res://scenes/minigames/FiletMinigame.tscn"
}

var pending_ocean_zone: int = 1
var world_spawn_hint: String = "default"
var current_world_key: String = ""
var current_world_scene: Node = null
var current_overlay: CanvasLayer = null
var current_minigame: CanvasLayer = null
var current_minigame_context: Dictionary = {}

func go_to_main_menu() -> void:
	current_world_key = ""
	_clear_world()
	_show_overlay("res://scenes/ui/MainMenu.tscn")

func go_to_town() -> void:
	world_spawn_hint = "town"
	await _set_world_scene(WORLD_SCENES["town"], TRANSITION_SLIDE_RIGHT)
	AudioManager.play_music("town_night" if GameState.is_night() else "town_day")

func go_to_beach() -> void:
	world_spawn_hint = "beach"
	await _set_world_scene(WORLD_SCENES["beach"], TRANSITION_SLIDE_RIGHT)
	AudioManager.play_music("beach")

func go_to_dock() -> void:
	world_spawn_hint = "dock"
	await _set_world_scene(WORLD_SCENES["dock"], TRANSITION_SLIDE_RIGHT)
	AudioManager.play_music("beach")

func go_to_ocean(zone: int) -> void:
	pending_ocean_zone = zone
	GameState.current_zone = zone
	world_spawn_hint = "ocean"
	await _set_world_scene(WORLD_SCENES["ocean"], TRANSITION_FADE_BLACK)
	AudioManager.play_music("ocean_z%d" % zone)

func show_shop() -> void:
	_show_overlay("res://scenes/ui/Shop.tscn")
	AudioManager.play_music("shop")

func show_inventory() -> void:
	_show_overlay("res://scenes/ui/Inventory.tscn")

func show_crafting() -> void:
	_show_overlay("res://scenes/ui/CraftingMenu.tscn")

func show_codex() -> void:
	_show_overlay("res://scenes/ui/Codex.tscn")

func show_day_end_summary() -> void:
	var overlay := _show_overlay("res://scenes/ui/DayEndSummary.tscn")
	if overlay and overlay.has_method("setup_summary"):
		overlay.setup_summary(GameState.last_day_summary)

func show_win_screen() -> void:
	AudioManager.play_music("win")
	_show_overlay("res://scenes/ui/WinScreen.tscn")

func show_game_over(reason: String) -> void:
	AudioManager.play_music("game_over")
	var overlay := _show_overlay("res://scenes/ui/GameOverScreen.tscn")
	if overlay and overlay.has_method("setup_reason"):
		overlay.setup_reason(reason)

func start_minigame(type: String, context: Dictionary = {}) -> void:
	if current_minigame != null:
		return
	var path := MINIGAME_SCENES.get(type, "")
	if path.is_empty():
		return
	var packed := load(path) as PackedScene
	if packed == null:
		return
	current_minigame_context = context.duplicate(true)
	current_minigame = packed.instantiate() as CanvasLayer
	if current_minigame == null:
		current_minigame = packed.instantiate()
	var main_root := _get_main_root()
	if main_root == null:
		return
	main_root.add_child(current_minigame)
	if current_minigame.has_method("setup_context"):
		current_minigame.setup_context(current_minigame_context)

func end_minigame() -> void:
	if current_minigame != null and is_instance_valid(current_minigame):
		current_minigame.queue_free()
	current_minigame = null
	current_minigame_context.clear()

func close_overlay() -> void:
	if current_overlay != null and is_instance_valid(current_overlay):
		current_overlay.queue_free()
	current_overlay = null

func show_dialogue(speaker_name: String, lines: Array[String], blip_key: String = "townsfolk_blip") -> Node:
	var dialogue_box := _get_dialogue_box()
	if dialogue_box and dialogue_box.has_method("open_dialogue"):
		dialogue_box.open_dialogue(speaker_name, lines, blip_key)
	return dialogue_box

func show_notification(text: String) -> void:
	var hud := _get_hud()
	if hud and hud.has_method("show_notification"):
		hud.show_notification(text)

func _show_overlay(path: String) -> CanvasLayer:
	close_overlay()
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	var overlay := packed.instantiate() as CanvasLayer
	if overlay == null:
		overlay = packed.instantiate()
	var main_root := _get_main_root()
	if main_root == null:
		return null
	main_root.add_child(overlay)
	current_overlay = overlay
	SaveSystem.save_state(GameState)
	return overlay

func _clear_world() -> void:
	if current_world_scene != null and is_instance_valid(current_world_scene):
		current_world_scene.queue_free()
	current_world_scene = null

func _set_world_scene(path: String, transition_type: String) -> void:
	close_overlay()
	await _transition_out(transition_type)
	var packed := load(path) as PackedScene
	if packed == null:
		return
	var world_container := _get_world_container()
	if world_container == null:
		return
	_clear_world()
	current_world_scene = packed.instantiate()
	world_container.add_child(current_world_scene)
	current_world_key = path.get_file().get_basename().to_lower()
	SaveSystem.save_state(GameState)
	await _transition_in(transition_type)

func _transition_out(transition_type: String) -> void:
	if transition_type == TRANSITION_INSTANT:
		return
	var fade_rect := _get_fade_rect()
	if fade_rect == null:
		await get_tree().create_timer(0.3).timeout
		return
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.3)
	await tween.finished

func _transition_in(transition_type: String) -> void:
	if transition_type == TRANSITION_INSTANT:
		return
	var fade_rect := _get_fade_rect()
	if fade_rect == null:
		await get_tree().create_timer(0.3).timeout
		return
	if transition_type == TRANSITION_SLIDE_RIGHT and current_world_scene != null:
		var viewport_width := get_viewport().get_visible_rect().size.x
		current_world_scene.position.x = viewport_width
		var slide_tween := create_tween()
		slide_tween.set_parallel(true)
		slide_tween.tween_property(current_world_scene, "position:x", 0.0, 0.3)
		slide_tween.tween_property(fade_rect, "color:a", 0.0, 0.3)
		await slide_tween.finished
	else:
		var tween := create_tween()
		tween.tween_property(fade_rect, "color:a", 0.0, 0.3)
		await tween.finished
	fade_rect.visible = false

func _get_main_root() -> Node:
	return get_tree().root.get_node_or_null("Main")

func _get_world_container() -> Node2D:
	var main_root := _get_main_root()
	if main_root == null:
		return null
	return main_root.get_node_or_null("WorldContainer")

func _get_fade_rect() -> ColorRect:
	var main_root := _get_main_root()
	if main_root == null:
		return null
	return main_root.get_node_or_null("TransitionLayer/FadeRect")

func _get_dialogue_box() -> Node:
	var main_root := _get_main_root()
	if main_root == null:
		return null
	return main_root.get_node_or_null("DialogueBox")

func _get_hud() -> Node:
	var main_root := _get_main_root()
	if main_root == null:
		return null
	return main_root.get_node_or_null("HUD")
