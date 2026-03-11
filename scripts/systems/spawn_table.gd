extends RefCounted
class_name SpawnTable

const TABLE_PATHS := {
	1: "res://resources/spawn_tables/spawn_table_zone1.tres",
	2: "res://resources/spawn_tables/spawn_table_zone2.tres",
	3: "res://resources/spawn_tables/spawn_table_zone3.tres",
	4: "res://resources/spawn_tables/spawn_table_zone4.tres"
}

static var _cache: Dictionary = {}
static var _rng := RandomNumberGenerator.new()
static var _initialized := false

static func roll_fish(zone: int) -> Dictionary:
	_initialize_rng()
	var table_resource := _load_table(zone)
	if table_resource == null:
		return {}
	var weights := ModifierStack.apply_spawn_multipliers(table_resource.fish_weights, zone)
	var total := 0.0
	for weight in weights.values():
		total += float(weight)
	if total <= 0.0:
		return {}
	var roll := _rng.randf() * total
	var cumulative := 0.0
	for fish_id_variant in weights.keys():
		var fish_id := String(fish_id_variant)
		cumulative += float(weights[fish_id])
		if roll <= cumulative:
			var fish_data := FishDatabase.get_fish(fish_id)
			if fish_data == null:
				return {}
			return FishDatabase.create_fish_instance(fish_data)
	return {}

static func _load_table(zone: int) -> SpawnTableData:
	if _cache.has(zone):
		return _cache[zone]
	var path := TABLE_PATHS.get(zone, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var table := load(path) as SpawnTableData
	_cache[zone] = table
	return table

static func _initialize_rng() -> void:
	if _initialized:
		return
	_rng.randomize()
	_initialized = true
