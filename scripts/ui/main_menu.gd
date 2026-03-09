extends Control

# main_menu.gd - Main menu controller

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready():
	new_game_button.pressed.connect(_on_new_game)
	continue_button.pressed.connect(_on_continue)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	
	continue_button.disabled = not SaveSystem.has_save()
	
	# Play menu music
	AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/GentleBreeze.ogg")

func _on_new_game():
	SaveSystem.delete_save()
	GameState.reset_game()
	GameState.start_new_game()
	SceneManager.change_scene("res://scenes/Main.tscn")

func _on_continue():
	var save_data = SaveSystem.load_game()
	SaveSystem.apply_save_data(save_data)
	SceneManager.change_scene(save_data.get("current_scene", "res://scenes/Main.tscn"))

func _on_settings():
	# Open settings menu
	var settings = preload("res://scenes/ui/SettingsMenu.tscn").instantiate()
	add_child(settings)

func _on_quit():
	get_tree().quit()
