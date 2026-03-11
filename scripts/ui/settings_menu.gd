extends Control

# settings_menu.gd - Settings menu controller

signal settings_closed()

@onready var master_volume: HSlider = $Panel/VBoxContainer/MasterVolume
@onready var music_volume: HSlider = $Panel/VBoxContainer/MusicVolume
@onready var sfx_volume: HSlider = $Panel/VBoxContainer/SFXVolume
@onready var fullscreen_check: CheckBox = $Panel/VBoxContainer/FullscreenCheck
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	master_volume.value_changed.connect(_on_master_changed)
	music_volume.value_changed.connect(_on_music_changed)
	sfx_volume.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_load_settings()

func _load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_volume.value = config.get_value("audio", "master", 100)
		music_volume.value = config.get_value("audio", "music", 80)
		sfx_volume.value = config.get_value("audio", "sfx", 100)
		fullscreen_check.button_pressed = config.get_value("display", "fullscreen", false)

func _save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master", master_volume.value)
	config.set_value("audio", "music", music_volume.value)
	config.set_value("audio", "sfx", sfx_volume.value)
	config.set_value("display", "fullscreen", fullscreen_check.button_pressed)
	config.save("user://settings.cfg")

func _on_master_changed(value: float):
	AudioManager.set_master_volume(value / 100.0)

func _on_music_changed(value: float):
	AudioManager.set_music_volume(value / 100.0)

func _on_sfx_changed(value: float):
	AudioManager.set_sfx_volume(value / 100.0)

func _on_fullscreen_toggled(is_fullscreen: bool):
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_close_pressed():
	_save_settings()
	settings_closed.emit()
	hide()
