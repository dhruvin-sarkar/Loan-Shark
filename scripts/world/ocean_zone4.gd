extends "res://scripts/world/ocean_zone_base.gd"

# ocean_zone4.gd - Bioluminescent Deep zone (zone 4)

func _ready():
	zone_name = "zone4"
	zone_depth = 4
	hazard_spawn_rate = 0.2
	super._ready()
	
	# Play zone 4 music
	AudioManager.play_music("res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/PolarLights.ogg")

func _setup_parallax():
	# Setup bioluminescent deep parallax layers
	# underwater-fantasy-files layers
	pass
