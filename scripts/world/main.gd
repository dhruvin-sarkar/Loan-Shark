extends Node2D

# main.gd - Root scene controller

var player: CharacterBody2D
var hud: CanvasLayer

func _ready():
	player = $Player
	hud = $HUD
	
	# Initialize game state
	if GameState.day == 1:
		GameState.start_new_game()

func _process(delta):
	# Handle global input
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		_show_pause_menu()
	else:
		_hide_pause_menu()

func _show_pause_menu():
	# Instantiate pause menu
	pass

func _hide_pause_menu():
	# Remove pause menu
	pass
