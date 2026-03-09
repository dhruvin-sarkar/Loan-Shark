extends Control

# win_screen.gd - Victory screen

signal main_menu_requested()

@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

func _ready():
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func show_victory(days_taken: int):
	stats_label.text = "Days taken: %d" % days_taken
	show()

func _on_main_menu_pressed():
	emit_signal("main_menu_requested")
	SceneManager.change_scene("res://scenes/ui/MainMenu.tscn")
