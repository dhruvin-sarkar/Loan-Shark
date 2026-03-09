extends "res://scripts/world/ocean_zone_base.gd"

# ocean_zone1.gd - Shallows zone (zone 1)

func _ready():
	zone_name = "zone1"
	zone_depth = 1
	hazard_spawn_rate = 0.05
	super._ready()
	
	# Play zone 1 music
	AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/WhisperingWoods.ogg")

func _setup_parallax():
	# Setup shallows parallax layers
	# Sinky_Sub_BG.png + Sinky_Sub_GodRays.png + Sinky_Sub_Floor.png
	pass
