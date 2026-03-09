extends Node2D

# town.gd - Town scene controller

var npcs: Array = []
var player_spawn: Marker2D

func _ready():
	player_spawn = $PlayerSpawn
	_setup_npcs()
	_setup_transitions()
	
	# Play town music based on time
	if GameState.is_night():
		AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/EveningHarmony.ogg")
	else:
		AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/GentleBreeze.ogg")

func _setup_npcs():
	# Find all NPCs in scene
	for child in get_children():
		if child.is_in_group("npc"):
			npcs.append(child)

func _setup_transitions():
	# Setup area transitions to beach and dock
	pass

func _on_beach_transition_body_entered(body):
	if body.is_in_group("player"):
		SceneManager.change_scene("res://scenes/world/Beach.tscn")

func _on_dock_transition_body_entered(body):
	if body.is_in_group("player"):
		SceneManager.change_scene("res://scenes/world/Dock.tscn")
