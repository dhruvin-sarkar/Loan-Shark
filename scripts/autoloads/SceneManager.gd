class_name SceneManager
extends Node

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

static var pending_ocean_zone: int = 1
static var world_spawn_hint: String = "default"
static var current_world_key: String = ""
static var current_world_scene: Node = null
static var current_overlay: CanvasLayer = null
static var current_minigame: CanvasLayer = null
static var current_minigame_context: Dictionary = {}

static func _get_singleton() -> Node:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var scene_tree: SceneTree = main_loop as SceneTree
		if scene_tree != null:
			return scene_tree.root.get_node_or_null("SceneManager")
	return null

static func go_to_main_menu() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_go_to_main_menu")

static func go_to_town() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_go_to_town")

static func go_to_beach() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_go_to_beach")

static func go_to_dock() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_go_to_dock")

static func go_to_ocean(zone: int) -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_go_to_ocean", zone)

static func show_shop() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_shop")

static func show_inventory() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_inventory")

static func show_crafting() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_crafting")

static func show_codex() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_codex")

static func show_day_end_summary() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_day_end_summary")

static func show_win_screen() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_win_screen")

static func show_game_over(reason: String) -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_game_over", reason)

static func start_minigame(type: String, context: Dictionary = {}) -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_start_minigame", type, context)

static func end_minigame() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_end_minigame")

static func close_overlay() -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_close_overlay")

static func show_dialogue(speaker_name: String, lines: Array[String], blip_key: String = "townsfolk_blip") -> Node:
	var manager: Node = _get_singleton()
	if manager != null:
		return manager.call("_show_dialogue", speaker_name, lines, blip_key) as Node
	return null

static func show_notification(text: String) -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_show_notification", text)

static func change_scene(path: String) -> void:
	var manager: Node = _get_singleton()
	if manager != null:
		manager.call("_change_scene", path)

func _go_to_main_menu() -> void:
	current_world_key = ""
	_clear_world()
	_show_overlay("res://scenes/ui/MainMenu.tscn")

func _go_to_town() -> void:
	world_spawn_hint = "town"
	await _set_world_scene(WORLD_SCENES["town"], TRANSITION_SLIDE_RIGHT)
	AudioManager.play_music("town_night" if GameState.is_night() else "town_day")

func _go_to_beach() -> void:
	world_spawn_hint = "beach"
	await _set_world_scene(WORLD_SCENES["beach"], TRANSITION_SLIDE_RIGHT)
	AudioManager.play_music("beach")

func _go_to_dock() -> void:
	world_spawn_hint = "dock"
	await _set_world_scene(WORLD_SCENES["dock"], TRANSITION_SLIDE_RIGHT)
	AudioManager.play_music("beach")

func _go_to_ocean(zone: int) -> void:
	pending_ocean_zone = zone
	GameState.current_zone = zone
	world_spawn_hint = "ocean"
	await _set_world_scene(WORLD_SCENES["ocean"], TRANSITION_FADE_BLACK)
	AudioManager.play_music("ocean_z%d" % zone)

func _show_shop() -> void:
	_show_overlay("res://scenes/ui/Shop.tscn")
	AudioManager.play_music("shop")

func _show_inventory() -> void:
	_show_overlay("res://scenes/ui/Inventory.tscn")

func _show_crafting() -> void:
	_show_overlay("res://scenes/ui/CraftingMenu.tscn")

func _show_codex() -> void:
	_show_overlay("res://scenes/ui/Codex.tscn")

func _show_day_end_summary() -> void:
	var overlay := _show_overlay("res://scenes/ui/DayEndSummary.tscn")
	if overlay and overlay.has_method("setup_summary"):
		overlay.setup_summary(GameState.last_day_summary)

func _show_win_screen() -> void:
	AudioManager.play_music("win")
	_show_overlay("res://scenes/ui/WinScreen.tscn")

func _show_game_over(reason: String) -> void:
	AudioManager.play_music("game_over")
	var overlay := _show_overlay("res://scenes/ui/GameOverScreen.tscn")
	if overlay and overlay.has_method("setup_reason"):
		overlay.setup_reason(reason)

func _start_minigame(type: String, context: Dictionary = {}) -> void:
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

func _end_minigame() -> void:
	if current_minigame != null and is_instance_valid(current_minigame):
		current_minigame.queue_free()
	current_minigame = null
	current_minigame_context.clear()

func _close_overlay() -> void:
	if current_overlay != null and is_instance_valid(current_overlay):
		current_overlay.queue_free()
	current_overlay = null

func _show_dialogue(speaker_name: String, lines: Array[String], blip_key: String = "townsfolk_blip") -> Node:
	var dialogue_box := _get_dialogue_box()
	if dialogue_box and dialogue_box.has_method("open_dialogue"):
		dialogue_box.open_dialogue(speaker_name, lines, blip_key)
	return dialogue_box

func _show_notification(text: String) -> void:
	var hud := _get_hud()
	if hud and hud.has_method("show_notification"):
		hud.show_notification(text)

func _change_scene(path: String) -> void:
	if path == "res://scenes/ui/MainMenu.tscn":
		_go_to_main_menu()
		return
	_set_world_scene(path, TRANSITION_FADE_BLACK)

func _show_overlay(path: String) -> CanvasLayer:
	_close_overlay()
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
	SaveSystem.save_state()
	return overlay

func _clear_world() -> void:
	if current_world_scene != null and is_instance_valid(current_world_scene):
		current_world_scene.queue_free()
	current_world_scene = null

func _set_world_scene(path: String, transition_type: String) -> void:
	_close_overlay()
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
	SaveSystem.save_state()
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
