extends CanvasLayer

@onready var new_game_button: Button = $Panel/NewGameButton
@onready var continue_button: Button = $Panel/ContinueButton
@onready var settings_button: Button = $Panel/SettingsButton

func _ready() -> void:
	continue_button.disabled = not SaveSystem.has_save()
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_new_game_pressed() -> void:
	SaveSystem.clear_save()
	GameState.reset_run()
	GameState.begin_next_day()
	SceneManager.close_overlay()
	SceneManager.go_to_town()

func _on_continue_pressed() -> void:
	if not SaveSystem.has_save():
		return
	GameState.load_save()
	GameState.is_day_active = true
	SceneManager.close_overlay()
	SceneManager.go_to_town()

func _on_settings_pressed() -> void:
	SceneManager.show_notification("Settings menu not wired yet")
