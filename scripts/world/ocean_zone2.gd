extends "res://scripts/world/ocean_zone_base.gd"

# ocean_zone2.gd - Kelp Forest zone (zone 2)

func _ready():
	zone_name = "zone2"
	zone_depth = 2
	hazard_spawn_rate = 0.1
	super._ready()
	
	# Play zone 2 music
	AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/ForgottenBiomes.ogg")

func _setup_parallax():
	# Setup kelp forest parallax layers
	# Sinky_Sub_Cliffs.png + Sinky_Sub_CloseRockKelp.png + Sinky_Sub_Floor.png
	pass
