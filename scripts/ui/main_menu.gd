extends Control

@export var parallax_strength: float = 0.05

@onready var parallax_bg: ParallaxBackground = $ParallaxBackground
@onready var continue_button: Button = $UILayer/ButtonContainer/ContinueButton

func _get_game_state() -> Node:
	return get_node_or_null("/root/GameState")

func _ready() -> void:
	# Only enable continue if a save file exists
	continue_button.disabled = not FileAccess.file_exists("user://save.json")

func _process(_delta: float) -> void:
	# Mouse parallax effect
	var screen_center = get_viewport_rect().size / 2.0
	var mouse_pos = get_viewport().get_mouse_position()
	var offset = (mouse_pos - screen_center) * parallax_strength
	parallax_bg.scroll_offset = offset

func _on_new_game_button_pressed() -> void:
	var state: Node = _get_game_state()
	if state != null:
		state.call("reset_run")
		state.set("is_day_active", true)
	SceneManager.go_to_town()

func _on_continue_button_pressed() -> void:
	var state: Node = _get_game_state()
	if state != null:
		state.call("load_save")
	SceneManager.go_to_town()

func _on_settings_button_pressed() -> void:
	pass # Settings not implemented yet
