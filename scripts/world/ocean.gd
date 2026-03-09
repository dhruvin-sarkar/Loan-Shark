extends Node2D

# ocean.gd - Ocean zone loader/manager

var current_zone: String = "zone1"
var zone_scenes: Dictionary = {
	"zone1": "res://scenes/world/ocean/OceanZone1_Shallows.tscn",
	"zone2": "res://scenes/world/ocean/OceanZone2_KelpForest.tscn",
	"zone3": "res://scenes/world/ocean/OceanZone3_SunkenRuins.tscn",
	"zone4": "res://scenes/world/ocean/OceanZone4_BiolumDeep.tscn"
}

func _ready():
	load_zone(current_zone)

func load_zone(zone: String):
	if zone_scenes.has(zone):
		current_zone = zone
		# Load zone scene
		var zone_scene = load(zone_scenes[zone])
		if zone_scene:
			var instance = zone_scene.instantiate()
			add_child(instance)

func transition_to_zone(target_zone: String):
	# Play zone transition effect
	await _play_zone_transition()
	
	# Remove current zone
	for child in get_children():
		if child.is_in_group("ocean_zone"):
			child.queue_free()
	
	# Load new zone
	load_zone(target_zone)

func _play_zone_transition():
	# Zone transition wipe animation
	await get_tree().create_timer(0.5).timeout

func get_current_zone() -> String:
	return current_zone
