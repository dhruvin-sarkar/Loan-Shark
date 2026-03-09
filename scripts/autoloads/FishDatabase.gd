extends Node

# FishDatabase.gd - Global lookup table for all 38+ fish (GDD v3.0 compliant)
# Does NOT contain spawn logic - that's handled by spawn_table.gd

signal fish_registered(fish_id: String, fish_data: Dictionary)

var fish_data: Dictionary = {}  # fish_id -> Dictionary
var spawn_tables: Dictionary = {}  # zone -> SpawnTable resource

# Complete fish roster loaded from resources
var all_fish_ids: Array = []

func _ready():
	load_fish_data()
	load_spawn_tables()

func load_fish_data():
	var zones = ["zone1", "zone2", "zone3", "zone4"]
	for zone in zones:
		var zone_path = "res://resources/fish_data/" + zone
		var dir = DirAccess.open(zone_path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tres"):
					var fish_id = file_name.replace(".tres", "")
					var fish_res = load(zone_path + "/" + file_name)
					if fish_res:
						# Convert resource to dictionary for GDD compliance
						var fish_dict = _resource_to_dict(fish_res, fish_id, zone)
						fish_data[fish_id] = fish_dict
						all_fish_ids.append(fish_id)
				file_name = dir.get_next()

func _resource_to_dict(res: Resource, fish_id: String, zone: String) -> Dictionary:
	return {
		"id": fish_id,
		"name": res.get("name", "Unknown"),
		"zone": zone,
		"base_price": res.get("base_price", 10),
		"size_range": res.get("size_range", [0.8, 1.8]),
		"rarity": res.get("rarity", "common"),
		"night_only": res.get("night_only", false),
		"family": res.get("family", "pelagic"),
		"reel_speed": res.get("reel_speed", 1.0),
		"catch_speed": res.get("catch_speed", 1.0),
		"modifier_effect": res.get("modifier_effect", ""),
		"description": res.get("description", ""),
		"texture_path": res.get("texture_path", "")
	}

func load_spawn_tables():
	for i in range(1, 5):
		var table_path = "res://resources/spawn_tables/spawn_table_zone" + str(i) + ".tres"
		if ResourceLoader.exists(table_path):
			spawn_tables["zone" + str(i)] = load(table_path)

# === LOOKUP METHODS ===

func get_fish_data(fish_id: String) -> Dictionary:
	return fish_data.get(fish_id, {})

func get_spawn_table(zone: String) -> Resource:
	return spawn_tables.get(zone, null)

func get_fish_by_zone(zone: String) -> Array:
	var result = []
	for fish_id in fish_data:
		if fish_data[fish_id].zone == zone:
			result.append(fish_id)
	return result

func get_fish_by_rarity(rarity: String) -> Array:
	var result = []
	for fish_id in fish_data:
		if fish_data[fish_id].rarity == rarity:
			result.append(fish_id)
	return result

func get_fish_by_family(family: String) -> Array:
	var result = []
	for fish_id in fish_data:
		if fish_data[fish_id].family == family:
			result.append(fish_id)
	return result

func get_night_only_fish() -> Array:
	var result = []
	for fish_id in fish_data:
		if fish_data[fish_id].night_only:
			result.append(fish_id)
	return result

# Returns a random fish_id weighted by spawn table
func get_random_fish(zone: String) -> String:
	var table = get_spawn_table(zone)
	if table and table.has_method("get_random_fish"):
		return table.get_random_fish()
	
	# Fallback: random from zone
	var zone_fish = get_fish_by_zone(zone)
	if zone_fish.size() > 0:
		return zone_fish.pick_random()
	return ""

# Returns fish data formatted for inventory entry
func create_fish_instance(fish_id: String, zone_caught: String = "", caught_at_night: bool = false) -> Dictionary:
	var data = get_fish_data(fish_id)
	if data.is_empty():
		return {}
	
	# Random size within range
	var size_mult = randf_range(data.size_range[0], data.size_range[1])
	
	return {
		"id": fish_id,
		"name": data.name,
		"base_price": data.base_price,
		"size_mult": size_mult,
		"reel_quality": 1.0,  # Set by Reel minigame
		"fileted": false,
		"filet_mult": 1.0,  # Set by Filet minigame
		"family": data.family,
		"rarity": data.rarity,
		"night_only": data.night_only,
		"zone_caught": zone_caught,
		"caught_at_night": caught_at_night
	}

# Get total fish count
func get_fish_count() -> int:
	return fish_data.size()

# Check if fish exists
func has_fish(fish_id: String) -> bool:
	return fish_data.has(fish_id)
