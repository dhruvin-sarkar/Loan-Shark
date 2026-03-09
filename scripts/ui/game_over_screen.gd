extends Control

# game_over_screen.gd - Game over screen

signal retry_requested()
signal main_menu_requested()

@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

func _ready():
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _on_retry_pressed():
	emit_signal("retry_requested")
	# Reset game and restart
	GameState.reset_game()
	SceneManager.change_scene("res://scenes/Main.tscn")

func _on_main_menu_pressed():
	emit_signal("main_menu_requested")
	SceneManager.change_scene("res://scenes/ui/MainMenu.tscn")
