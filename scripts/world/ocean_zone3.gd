extends "res://scripts/world/ocean_zone_base.gd"

# ocean_zone3.gd - Sunken Ruins zone (zone 3)

func _ready():
	zone_name = "zone3"
	zone_depth = 3
	hazard_spawn_rate = 0.15
	super._ready()
	
	# Play zone 3 music
	AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/StrangeWorlds.ogg")

func _setup_parallax():
	# Setup sunken ruins parallax layers
	# Sinky_Sub_Ruins_Whale.png + Sinky_Sub_Floor.png
	pass
