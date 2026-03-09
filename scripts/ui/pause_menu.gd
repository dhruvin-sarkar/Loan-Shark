extends Control

# pause_menu.gd - Pause menu controller

signal resume_pressed()
signal settings_pressed()
signal main_menu_pressed()

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()

func show_menu():
	show()
	get_tree().paused = true

func hide_menu():
	hide()
	get_tree().paused = false

func _on_resume_pressed():
	hide_menu()
	emit_signal("resume_pressed")

func _on_settings_pressed():
	emit_signal("settings_pressed")

func _on_main_menu_pressed():
	hide_menu()
	emit_signal("main_menu_pressed")
	SceneManager.change_scene("res://scenes/ui/MainMenu.tscn")
