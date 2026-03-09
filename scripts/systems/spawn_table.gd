extends Resource

# spawn_table.gd - Defines fish spawn probabilities per zone (GDD v3.0 compliant)

class_name SpawnTable

@export var zone_name: String = ""
@export var fish_weights: Dictionary = {}
@export var night_only_fish: Array = []  # Fish that only spawn at night
@export var legendary_cap_fish: Array = []  # Fish limited to 1 per day (e.g., coelacanth)

# Get a random fish, considering time of day and legendary caps
# is_night: true if current time is in last 25% of day (150 seconds remaining of 600)
# caught_legendary_today: array of legendary fish IDs already caught today
func get_random_fish(is_night: bool = false, caught_legendary_today: Array = []) -> String:
	var active_weights: Dictionary = {}
	var total_weight: float = 0.0
	
	for fish_id in fish_weights:
		# Skip night-only fish during daytime
		if fish_id in night_only_fish and not is_night:
			continue
		
		# Skip legendary fish already caught today
		if fish_id in legendary_cap_fish and fish_id in caught_legendary_today:
			continue
		
		var weight = fish_weights[fish_id]
		active_weights[fish_id] = weight
		total_weight += weight
	
	if total_weight <= 0.0:
		return ""
	
	var random_value = randf() * total_weight
	var current_weight: float = 0.0
	
	for fish_id in active_weights:
		current_weight += active_weights[fish_id]
		if random_value <= current_weight:
			return fish_id
	
	return ""

# Legacy function for backward compatibility
func get_random_fish_legacy() -> String:
	return get_random_fish(false, [])

func get_fish_by_rarity(rarity: String) -> Array:
	var result: Array = []
	for fish_id in fish_weights:
		var fish_data = FishDatabase.get_fish_data(fish_id)
		if fish_data and fish_data.get("rarity", "common") == rarity:
			result.append(fish_id)
	return result

func add_fish(fish_id: String, weight: float):
	fish_weights[fish_id] = weight

func remove_fish(fish_id: String):
	fish_weights.erase(fish_id)

func get_normalized_weights(is_night: bool = false) -> Dictionary:
	var total: float = 0.0
	var normalized: Dictionary = {}
	
	for fish_id in fish_weights:
		if fish_id in night_only_fish and not is_night:
			continue
		total += fish_weights[fish_id]
	
	for fish_id in fish_weights:
		if fish_id in night_only_fish and not is_night:
			continue
		normalized[fish_id] = fish_weights[fish_id] / total if total > 0 else 0.0
	
	return normalized
