extends Node
class_name FishDatabase

const FISH_PATHS: Array[String] = [
	"res://resources/fish_data/zone1/sardine.tres",
	"res://resources/fish_data/zone1/bass.tres",
	"res://resources/fish_data/zone1/crab.tres",
	"res://resources/fish_data/zone1/clownfish.tres",
	"res://resources/fish_data/zone1/seahorse.tres",
	"res://resources/fish_data/zone1/pufferfish.tres",
	"res://resources/fish_data/zone1/flounder.tres",
	"res://resources/fish_data/zone1/perch.tres",
	"res://resources/fish_data/zone1/shrimp.tres",
	"res://resources/fish_data/zone1/jellyfish.tres",
	"res://resources/fish_data/zone2/snapper.tres",
	"res://resources/fish_data/zone2/moray_small.tres",
	"res://resources/fish_data/zone2/grouper.tres",
	"res://resources/fish_data/zone2/trumpet_fish.tres",
	"res://resources/fish_data/zone2/spiny_lobster.tres",
	"res://resources/fish_data/zone2/stonefish.tres",
	"res://resources/fish_data/zone2/octopus_small.tres",
	"res://resources/fish_data/zone2/needlefish.tres",
	"res://resources/fish_data/zone2/batfish.tres",
	"res://resources/fish_data/zone2/ghost_crab.tres",
	"res://resources/fish_data/zone3/anglerfish.tres",
	"res://resources/fish_data/zone3/moray_large.tres",
	"res://resources/fish_data/zone3/oarfish.tres",
	"res://resources/fish_data/zone3/viperfish.tres",
	"res://resources/fish_data/zone3/dragonfish_juv.tres",
	"res://resources/fish_data/zone3/rugose_crab.tres",
	"res://resources/fish_data/zone3/coelacanth.tres",
	"res://resources/fish_data/zone3/abyssal_shrimp.tres",
	"res://resources/fish_data/zone3/stone_crab.tres",
	"res://resources/fish_data/zone3/phantom_eel.tres",
	"res://resources/fish_data/zone4/gulper_eel.tres",
	"res://resources/fish_data/zone4/dragonfish_adult.tres",
	"res://resources/fish_data/zone4/deep_angler.tres",
	"res://resources/fish_data/zone4/barreleye.tres",
	"res://resources/fish_data/zone4/fangtooth.tres",
	"res://resources/fish_data/zone4/frilled_shark.tres",
	"res://resources/fish_data/zone4/goldfish_modifier.tres",
	"res://resources/fish_data/zone4/lanternfish.tres",
	"res://resources/fish_data/zone4/sea_angel.tres",
	"res://resources/fish_data/zone4/midnight_leviathan.tres"
]

var _fish_lookup: Dictionary = {}
var _fish_list: Array[FishData] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_fish_lookup.clear()
	_fish_list.clear()
	for path in FISH_PATHS:
		if not ResourceLoader.exists(path):
			push_error("Missing fish resource: %s" % path)
			continue
		var fish_resource := load(path) as FishData
		if fish_resource == null:
			push_error("Invalid fish resource: %s" % path)
			continue
		_fish_lookup[fish_resource.id] = fish_resource
		_fish_list.append(fish_resource)

func get_fish(id: String) -> FishData:
	return _fish_lookup.get(id, null)

func get_all_fish() -> Array[FishData]:
	return _fish_list.duplicate()

func create_fish_instance(fish_data: FishData) -> Dictionary:
	var size_min := fish_data.size_range.x
	var size_max := fish_data.size_range.y
	var size_roll: float
	if GameState.equipped_rod == "rod_leviathan":
		size_roll = lerp(size_min, size_max, sqrt(_rng.randf()))
	else:
		size_roll = _rng.randf_range(size_min, size_max)
	return {
		"id": fish_data.id,
		"name": fish_data.name,
		"base_price": fish_data.base_price,
		"size_mult": size_roll,
		"reel_quality": 0.0,
		"fileted": false,
		"filet_mult": 1.0,
		"zone_caught": GameState.current_zone,
		"caught_at_night": GameState.is_night(),
		"family": fish_data.family,
		"rarity": fish_data.rarity,
		"modifier_effect": fish_data.modifier_effect,
		"inventory_slots": fish_data.inventory_slots,
		"stack_count": 5 if fish_data.id == "lanternfish" else 1,
		"sprite_region": fish_data.sprite_region
	}
