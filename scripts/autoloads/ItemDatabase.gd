extends Node

# ItemDatabase.gd - Manages all item data (GDD v3.0 compliant)
# Rods, Baits, Knives, Charms, Materials

signal item_registered(item_id: String, item_data: Dictionary)

var rods: Dictionary = {}      # rod_id -> Dictionary
var baits: Dictionary = {}     # bait_id -> Dictionary
var knives: Dictionary = {}   # knife_id -> Dictionary
var charms: Dictionary = {}   # charm_id -> Dictionary
var materials: Dictionary = {} # material_id -> Dictionary
var enchantments: Dictionary = {} # enchantment_id -> Dictionary

# Rod tier definitions per GDD
const ROD_TIERS = {
	"starter": ["rod_driftwood"],
	"amateur": ["rod_shell", "rod_coral", "rod_bone"],
	"intermediate": ["rod_kelp", "rod_deep", "rod_fossil"],
	"pro": ["rod_abyss", "rod_leviathan", "rod_oracle"]
}

# Zone access per rod tier - Pro rods only unlock Zone 3, Zone 4 requires Deep Bait
const ZONE_ACCESS = {
	"starter": 1,
	"amateur": 1,
	"intermediate": 2,
	"pro": 3
}

func _ready():
	load_rods()
	load_baits()
	load_knives()
	load_charms()
	load_materials()
	load_enchantments()

func load_rods():
	var path = "res://resources/rod_data"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var rod_id = file_name.replace(".tres", "")
				var rod_res = load(path + "/" + file_name)
				if rod_res:
					rods[rod_id] = _rod_to_dict(rod_res, rod_id)
			file_name = dir.get_next()

func _rod_to_dict(res: Resource, rod_id: String) -> Dictionary:
	var tier = "starter"
	for t in ROD_TIERS:
		if rod_id in ROD_TIERS[t]:
			tier = t
			break
	
	return {
		"id": rod_id,
		"name": res.get("name", "Unknown Rod"),
		"description": res.get("description", ""),
		"price": res.get("base_price", 0),
		"tier": tier,
		"max_zone": ZONE_ACCESS.get(tier, 1),
		"cast_power": res.get("cast_power", 1.0),
		"reel_speed": res.get("reel_speed", 1.0),
		"durability": res.get("durability", 100),
		"luck_bonus": res.get("luck_bonus", 0.0),
		"family_affinity": res.get("family_affinity", ""),
		"affinity_bonus": res.get("affinity_bonus", 1.0),
		"texture_path": res.get("texture_path", "")
	}

func load_baits():
	var path = "res://resources/bait_data"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var bait_id = file_name.replace(".tres", "")
				var bait_res = load(path + "/" + file_name)
				if bait_res:
					baits[bait_id] = _bait_to_dict(bait_res, bait_id)
			file_name = dir.get_next()

func _bait_to_dict(res: Resource, bait_id: String) -> Dictionary:
	return {
		"id": bait_id,
		"name": res.get("name", "Unknown Bait"),
		"description": res.get("description", ""),
		"price": res.get("base_price", 0),
		"catch_bonus": res.get("catch_bonus", 0.1),
		"rarity_bonus": res.get("rarity_bonus", 0.0),
		"uses": res.get("uses", 10),
		"spawn_bonus": res.get("spawn_bonus", 1.0),
		"target_family": res.get("target_family", ""),
		"family_bonus": res.get("family_bonus", 1.0),
		"deep_access": bait_id in ["bait_deep_sea_lure", "bait_luminous_lure"],
		"texture_path": res.get("texture_path", "")
	}

func load_knives():
	var path = "res://resources/knife_data"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var knife_id = file_name.replace(".tres", "")
				var knife_res = load(path + "/" + file_name)
				if knife_res:
					knives[knife_id] = _knife_to_dict(knife_res, knife_id)
			file_name = dir.get_next()

func _knife_to_dict(res: Resource, knife_id: String) -> Dictionary:
	return {
		"id": knife_id,
		"name": res.get("name", "Unknown Knife"),
		"description": res.get("description", ""),
		"price": res.get("base_price", 0),
		"filet_speed": res.get("filet_speed", 1.0),
		"material_yield": res.get("material_yield", 1.0),
		"durability": res.get("durability", 50),
		"texture_path": res.get("texture_path", "")
	}

func load_charms():
	var categories = ["sell_charms", "spawn_charms", "enchantment_charms"]
	for category in categories:
		var path = "res://resources/charm_data/" + category
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tres"):
					var charm_id = file_name.replace(".tres", "")
					var charm_res = load(path + "/" + file_name)
					if charm_res:
						charms[charm_id] = _charm_to_dict(charm_res, charm_id, category)
				file_name = dir.get_next()

func _charm_to_dict(res: Resource, charm_id: String, category: String) -> Dictionary:
	var charm_type = "sell"
	if "spawn" in category:
		charm_type = "spawn"
	elif "enchantment" in category:
		charm_type = "enchantment"
	
	return {
		"id": charm_id,
		"name": res.get("name", "Unknown Charm"),
		"description": res.get("description", ""),
		"charm_type": charm_type,
		"effect_value": res.get("effect_value", 0.1),
		"target": res.get("target", ""),
		"price": res.get("base_price", 0),
		"texture_path": res.get("texture_path", "")
	}

func load_materials():
	var path = "res://resources/material_data"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var mat_id = file_name.replace(".tres", "")
				var mat_res = load(path + "/" + file_name)
				if mat_res:
					materials[mat_id] = _material_to_dict(mat_res, mat_id)
			file_name = dir.get_next()

func _material_to_dict(res: Resource, mat_id: String) -> Dictionary:
	return {
		"id": mat_id,
		"name": res.get("name", "Unknown Material"),
		"description": res.get("description", ""),
		"rarity": res.get("rarity", "common"),
		"stack_size": res.get("stack_size", 99),
		"texture_path": res.get("texture_path", "")
	}

func load_enchantments():
	# 8 rod enchantments per GDD Section 9
	enchantments = {
		"tide_blessing": {
			"id": "tide_blessing",
			"name": "Tide Blessing",
			"description": "+15% sell price on all fish.",
			"effect": "sell_bonus",
			"value": 1.15
		},
		"deep_lure": {
			"id": "deep_lure",
			"name": "Deep Lure",
			"description": "Deep family fish +25% sell price.",
			"effect": "deep_sell",
			"value": 1.25
		},
		"fortune_hook": {
			"id": "fortune_hook",
			"name": "Fortune Hook",
			"description": "+10% rare fish spawn weight.",
			"effect": "rarity_spawn",
			"value": 1.1
		},
		"ghost_bait": {
			"id": "ghost_bait",
			"name": "Ghost Bait",
			"description": "Night-only fish spawn during day too.",
			"effect": "night_fish_day",
			"value": true
		},
		"calm_waters": {
			"id": "calm_waters",
			"name": "Calm Waters",
			"description": "Reel bar oscillation reduced by 20%.",
			"effect": "reel_speed",
			"value": 0.8
		},
		"blood_tide": {
			"id": "blood_tide",
			"name": "Blood Tide",
			"description": "Shark/shark-like fish +40% sell price but shark hazard rate +50%.",
			"effect": "shark_bonus",
			"value": 1.4
		},
		"echo_line": {
			"id": "echo_line",
			"name": "Echo Line",
			"description": "Double material drops from foraging.",
			"effect": "material_drops",
			"value": 2.0
		},
		"weighted_sink": {
			"id": "weighted_sink",
			"name": "Weighted Sink",
			"description": "Hook sinks 50% faster (less waiting for bites).",
			"effect": "sink_speed",
			"value": 1.5
		}
	}

# === LOOKUP METHODS ===

func get_rod(rod_id: String) -> Dictionary:
	return rods.get(rod_id, {})

func get_bait(bait_id: String) -> Dictionary:
	return baits.get(bait_id, {})

func get_knife(knife_id: String) -> Dictionary:
	return knives.get(knife_id, {})

func get_charm(charm_id: String) -> Dictionary:
	return charms.get(charm_id, {})

func get_material(mat_id: String) -> Dictionary:
	return materials.get(mat_id, {})

func get_enchantment(enchant_id: String) -> Dictionary:
	return enchantments.get(enchant_id, {})

# === ROD TIER CHECKS ===

func get_rod_tier(rod_id: String) -> String:
	var rod = get_rod(rod_id)
	return rod.get("tier", "starter")

func get_max_zone(rod_id: String) -> int:
	var rod = get_rod(rod_id)
	return rod.get("max_zone", 1)

func can_access_zone(rod_id: String, zone: int) -> bool:
	return get_max_zone(rod_id) >= zone

func get_rods_by_tier(tier: String) -> Array:
	var result = []
	for rod_id in rods:
		if rods[rod_id].tier == tier:
			result.append(rod_id)
	return result

# === BAIT CHECKS ===

func is_deep_bait(bait_id: String) -> bool:
	var bait = get_bait(bait_id)
	return bait.get("deep_access", false)

# === SHOP INVENTORY ===

func get_shop_items() -> Dictionary:
	return {
		"rods": rods.keys(),
		"baits": baits.keys(),
		"knives": knives.keys()
	}
