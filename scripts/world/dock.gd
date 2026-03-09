extends Node2D

# dock.gd - Dock scene controller

var player_spawn: Marker2D
var shopkeeper: Area2D

func _ready():
	player_spawn = $PlayerSpawn
	_setup_transitions()
	
	# Play dock music
	AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/FloatingDream.ogg")
	AudioManager.play_ambient("res://Assets/audio/SeaBreeze.ogg")

func _setup_transitions():
	pass

func _on_beach_transition_body_entered(body):
	if body.is_in_group("player"):
		AudioManager.stop_ambient()
		SceneManager.change_scene("res://scenes/world/Beach.tscn")

func _on_ocean_transition_body_entered(body):
	if body.is_in_group("player"):
		AudioManager.stop_ambient()
		SceneManager.change_scene("res://scenes/world/ocean/Ocean.tscn")

func _on_shopkeeper_interacted():
	# Open shop UI
	pass
