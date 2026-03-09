extends Node2D

# beach.gd - Beach scene controller

var player_spawn: Marker2D
var fishing_spots: Array = []

func _ready():
	player_spawn = $PlayerSpawn
	_setup_fishing_spots()
	_setup_transitions()
	
	# Play beach music
	AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/FloatingDream.ogg")
	AudioManager.play_ambient("res://Assets/audio/SeaBreeze.ogg")

func _setup_fishing_spots():
	for child in get_children():
		if child.is_in_group("fishing_spot"):
			fishing_spots.append(child)

func _setup_transitions():
	pass

func _on_town_transition_body_entered(body):
	if body.is_in_group("player"):
		AudioManager.stop_ambient()
		SceneManager.change_scene("res://scenes/world/Town.tscn")

func _on_dock_transition_body_entered(body):
	if body.is_in_group("player"):
		AudioManager.stop_ambient()
		SceneManager.change_scene("res://scenes/world/Dock.tscn")
