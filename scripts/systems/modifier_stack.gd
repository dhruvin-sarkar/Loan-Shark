extends RefCounted
class_name ModifierStack

const RARE_PLUS_RARITIES := ["rare", "ultra-rare", "legendary"]
const ULTRA_RARITIES := ["ultra-rare", "legendary"]
const PREDATOR_FISH := [
	"moray_small",
	"grouper",
	"anglerfish",
	"dragonfish_juv",
	"dragonfish_adult",
	"viperfish",
	"frilled_shark",
	"fangtooth",
	"deep_angler",
	"gulper_eel",
	"moray_large"
]

const FISH_FAMILIES := {
	"sardine": "pelagic",
	"bass": "bony",
	"crab": "crustacean",
	"clownfish": "reef",
	"seahorse": "reef",
	"pufferfish": "bony",
	"flounder": "bony",
	"perch": "bony",
	"shrimp": "crustacean",
	"jellyfish": "pelagic",
	"snapper": "bony",
	"moray_small": "eel",
	"grouper": "bony",
	"trumpet_fish": "reef",
	"spiny_lobster": "crustacean",
	"stonefish": "bony",
	"octopus_small": "cephalopod",
	"needlefish": "pelagic",
	"batfish": "reef",
	"ghost_crab": "crustacean",
	"anglerfish": "deep",
	"moray_large": "eel",
	"oarfish": "bony",
	"viperfish": "deep",
	"dragonfish_juv": "deep",
	"rugose_crab": "crustacean",
	"coelacanth": "bony",
	"abyssal_shrimp": "crustacean",
	"stone_crab": "crustacean",
	"phantom_eel": "eel",
	"gulper_eel": "eel",
	"dragonfish_adult": "deep",
	"deep_angler": "deep",
	"barreleye": "deep",
	"fangtooth": "deep",
	"frilled_shark": "deep",
	"goldfish_modifier": "deep",
	"lanternfish": "pelagic",
	"sea_angel": "deep",
	"midnight_leviathan": "deep"
}

static var goldfish_bonus_active: bool = false
static var sea_angel_active: bool = false
static var perfect_cast_bonus_active: bool = false
static var fortune_cast_counter: int = 0
static var echo_line_fish_id: String = ""
static var echo_line_casts_remaining: int = 0
static var gold_charm_sales_remaining: int = 0

static func reset_for_new_day() -> void:
	goldfish_bonus_active = false
	sea_angel_active = false
	perfect_cast_bonus_active = false
	fortune_cast_counter = 0
	echo_line_fish_id = ""
	echo_line_casts_remaining = 0
	gold_charm_sales_remaining = 0

static func set_perfect_cast_bonus(active: bool) -> void:
	perfect_cast_bonus_active = active

static func record_successful_catch(fish: Dictionary) -> void:
	if GameState.rod_enchantment == "echo_line":
		echo_line_fish_id = String(fish.get("id", ""))
		echo_line_casts_remaining = 3

static func apply_spawn_multipliers(base_table: Dictionary, zone: int) -> Dictionary:
	var modified := base_table.duplicate(true)
	var rod := GameState.equipped_rod
	var enchantment := GameState.rod_enchantment
	var bait := GameState.equipped_bait
	var active_charms: Array = GameState.active_charms.duplicate(true)

	for fish_id in modified.keys():
		var fish_data := FishDatabase.get_fish(String(fish_id))
		if fish_data == null:
			modified[fish_id] = 0.0
			continue
		var weight := float(modified.get(fish_id, 0.0))
		if fish_data.night_only and not GameState.is_night() and enchantment != "ghost_bait":
			weight = 0.0
		if fish_data.id == "coelacanth" and GameState.coelacanth_caught_today:
			weight = 0.0
		weight *= _rod_spawn_multiplier(rod, fish_data, zone)
		weight *= _enchantment_spawn_multiplier(enchantment, fish_data, zone)
		weight *= _bait_spawn_multiplier(bait, fish_data, zone)
		weight *= _charm_spawn_multiplier(active_charms, fish_data, zone)
		if perfect_cast_bonus_active and fish_data.rarity in RARE_PLUS_RARITIES:
			weight *= 1.1
		if echo_line_casts_remaining > 0 and fish_data.id == echo_line_fish_id:
			weight *= 1.15
		modified[fish_id] = max(weight, 0.0)
	perfect_cast_bonus_active = false
	if echo_line_casts_remaining > 0:
		echo_line_casts_remaining -= 1
		if echo_line_casts_remaining == 0:
			echo_line_fish_id = ""
	fortune_cast_counter += 1
	if enchantment == "fortune_hook" and fortune_cast_counter % 7 == 0:
		for fish_id in modified.keys():
			var fish_data := FishDatabase.get_fish(String(fish_id))
			if fish_data and fish_data.rarity not in RARE_PLUS_RARITIES:
				modified[fish_id] = 0.0
	return _normalize_weights(modified)

static func apply_sell_multipliers(price: float, fish: Dictionary) -> float:
	var final_price := price
	final_price *= _rod_sell_multiplier(GameState.equipped_rod)
	final_price *= _enchantment_sell_multiplier(GameState.rod_enchantment, fish)
	final_price *= _charm_sell_multiplier(GameState.active_charms, fish)
	if goldfish_bonus_active:
		final_price *= 1.5
		goldfish_bonus_active = false
	final_price = round(final_price * 100.0) / 100.0
	return final_price

static func trigger_modifier(effect: String) -> void:
	match effect:
		"leviathan_debt_clear":
			GameState.debt = round(GameState.debt * 0.8 * 100.0) / 100.0
			GameState.emit_debt_changed()
			SceneManager.show_notification("DEBT -20%!")
		"sea_angel_charm_double":
			sea_angel_active = true
			SceneManager.show_notification("CHARMS DOUBLED")
		"goldfish_next_sale_bonus":
			goldfish_bonus_active = true
			SceneManager.show_notification("GOLDEN SALE")
		"ghost_crab_night_bonus":
			pass

static func get_hazard_multiplier() -> float:
	var multiplier := 1.0
	if GameState.equipped_rod == "rod_oracle":
		multiplier *= 1.3
	if GameState.rod_enchantment == "blood_tide":
		multiplier *= 1.5
	if GameState.active_charms.has("charm_calm_tide"):
		var calm_multiplier := 0.7
		if sea_angel_active:
			calm_multiplier = max(0.0, 1.0 + ((calm_multiplier - 1.0) * 2.0))
		multiplier *= calm_multiplier
	if GameState.active_charms.has("charm_frenzy"):
		var frenzy_multiplier := 1.2
		if sea_angel_active:
			frenzy_multiplier = _double_effect(frenzy_multiplier)
		multiplier *= frenzy_multiplier
	return multiplier

static func _normalize_weights(weights: Dictionary) -> Dictionary:
	var total := 0.0
	for value in weights.values():
		total += float(value)
	if total <= 0.0:
		return weights
	var normalized := {}
	for fish_id in weights.keys():
		normalized[fish_id] = float(weights[fish_id]) / total
	return normalized

static func _rod_spawn_multiplier(rod_id: String, fish_data: FishData, zone: int) -> float:
	match rod_id:
		"rod_shell":
			return 1.2 if zone == 1 and fish_data.family == "crustacean" else 1.0
		"rod_coral":
			return 1.2 if zone == 1 and fish_data.family == "reef" else 1.0
		"rod_bone":
			return 1.25 if zone == 1 and fish_data.family == "bony" else 1.0
		"rod_kelp":
			return 1.25 if zone == 2 else 1.0
		"rod_deep":
			return 1.3 if zone == 2 and fish_data.id in ["grouper", "spiny_lobster", "stonefish"] else 1.0
		"rod_abyss":
			return 1.35 if zone == 4 and fish_data.rarity in ULTRA_RARITIES else 1.0
		"rod_oracle":
			return 1.15
		_:
			return 1.0

static func _enchantment_spawn_multiplier(enchantment_id: String, fish_data: FishData, zone: int) -> float:
	match enchantment_id:
		"deep_lure":
			return 1.4 if zone >= 3 and fish_data.rarity in RARE_PLUS_RARITIES else 1.0
		"blood_tide":
			return 1.3 if fish_data.rarity in RARE_PLUS_RARITIES else 1.0
		"ghost_bait":
			return 1.0
		_:
			return 1.0

static func _bait_spawn_multiplier(bait_id: String, fish_data: FishData, zone: int) -> float:
	match bait_id:
		"earthworm":
			return 1.25 if fish_data.family == "bony" else 1.0
		"maggot":
			return 1.3 if fish_data.rarity == "common" else 1.0
		"insect":
			if fish_data.family == "reef":
				return 1.2
			if fish_data.family == "pelagic":
				return 1.15
		"live_shrimp":
			return 1.35 if fish_data.family == "crustacean" else 1.0
		"sand_crab":
			return 1.3 if fish_data.family == "eel" or fish_data.family == "deep" else 1.0
		"smallfish":
			return 1.4 if PREDATOR_FISH.has(fish_data.id) else 1.0
		"soft_plastic":
			if fish_data.family == "bony":
				return 1.2
			if fish_data.family == "reef":
				return 1.15
		"jerkbait":
			return 1.25 if fish_data.id in ["needlefish", "viperfish", "fangtooth"] else 1.0
		"jig":
			return 1.25 if fish_data.family == "deep" else 1.0
		"spinner":
			return 1.3 if fish_data.family == "crustacean" or fish_data.family == "cephalopod" else 1.0
		"deep_sea_lure":
			return 1.25 if zone >= 3 else 1.0
		"luminous_lure":
			return 1.4 if zone == 4 and fish_data.rarity in ULTRA_RARITIES else 1.0
	return 1.0

static func _charm_spawn_multiplier(charm_ids: Array, fish_data: FishData, zone: int) -> float:
	var multiplier := 1.0
	var shared_family_multiplier := 1.0
	var family_hits := 0
	for charm_id_variant in charm_ids:
		var charm_id := String(charm_id_variant)
		var charm_multiplier := 1.0
		match charm_id:
			"charm_eel_ward":
				charm_multiplier = 0.5 if fish_data.family == "eel" else 1.0
			"charm_siren":
				charm_multiplier = 1.3 if fish_data.family == "pelagic" else 1.0
			"charm_crustacean_call":
				charm_multiplier = 1.4 if fish_data.family == "crustacean" else 1.0
			"charm_bony_lure":
				charm_multiplier = 1.35 if fish_data.family == "bony" else 1.0
			"charm_depth_pulse":
				charm_multiplier = 1.4 if zone >= 3 and fish_data.family == "deep" else 1.0
			"charm_fortune_bait":
				charm_multiplier = 1.2 if fish_data.rarity in RARE_PLUS_RARITIES else 1.0
			"charm_frenzy":
				charm_multiplier = 1.5
		if sea_angel_active and charm_multiplier != 1.0:
			charm_multiplier = _double_effect(charm_multiplier)
		if charm_id in ["charm_siren", "charm_crustacean_call", "charm_bony_lure", "charm_depth_pulse"] and fish_data.family == _family_for_charm(charm_id):
			family_hits += 1
			shared_family_multiplier = max(shared_family_multiplier, charm_multiplier)
		else:
			multiplier *= charm_multiplier
	if family_hits >= 2:
		multiplier *= 1.5
	else:
		multiplier *= shared_family_multiplier
	return multiplier

static func _rod_sell_multiplier(rod_id: String) -> float:
	match rod_id:
		"rod_fossil":
			return 1.2
		"rod_oracle":
			return 1.1
		_:
			return 1.0

static func _enchantment_sell_multiplier(enchantment_id: String, fish: Dictionary) -> float:
	if enchantment_id == "tide_blessing" and int(fish.get("zone_caught", 1)) <= 2 and String(fish.get("rarity", "common")) == "common":
		return 1.2
	return 1.0

static func _charm_sell_multiplier(charm_ids: Array, fish: Dictionary) -> float:
	var multiplier := 1.0
	var family_multiplier := 1.0
	var family_hits := 0
	var fish_family := String(fish.get("family", FISH_FAMILIES.get(String(fish.get("id", "")), "")))
	var fish_rarity := String(fish.get("rarity", "common"))
	var fish_id := String(fish.get("id", ""))
	for charm_id_variant in charm_ids:
		var charm_id := String(charm_id_variant)
		var charm_multiplier := 1.0
		match charm_id:
			"charm_shell":
				charm_multiplier = 1.25 if fish_family == "crustacean" else 1.0
			"charm_coral":
				charm_multiplier = 1.3 if fish_family == "reef" else 1.0
			"charm_deep":
				charm_multiplier = 1.35 if fish_family == "deep" else 1.0
			"charm_tide":
				charm_multiplier = 1.2
			"charm_gold":
				if gold_charm_sales_remaining == 0:
					gold_charm_sales_remaining = 3
				if gold_charm_sales_remaining > 0:
					charm_multiplier = 1.5
					gold_charm_sales_remaining -= 1
			"charm_night":
				var fish_data := FishDatabase.get_fish(fish_id)
				charm_multiplier = 1.4 if fish_data and fish_data.night_only else 1.0
			"charm_blood":
				charm_multiplier = 1.6 if fish_rarity == "rare" or fish_rarity == "ultra-rare" else 1.0
			"charm_ink":
				charm_multiplier = 1.25 if fish_family == "cephalopod" else 1.0
		if sea_angel_active and charm_multiplier != 1.0:
			charm_multiplier = _double_effect(charm_multiplier)
		if charm_id in ["charm_shell", "charm_coral", "charm_deep", "charm_ink"] and fish_family == _family_for_charm(charm_id):
			family_hits += 1
			family_multiplier = max(family_multiplier, charm_multiplier)
		else:
			multiplier *= charm_multiplier
	if family_hits >= 2:
		multiplier *= 1.5
	else:
		multiplier *= family_multiplier
	return multiplier

static func _family_for_charm(charm_id: String) -> String:
	match charm_id:
		"charm_shell", "charm_crustacean_call":
			return "crustacean"
		"charm_coral":
			return "reef"
		"charm_deep", "charm_depth_pulse":
			return "deep"
		"charm_siren":
			return "pelagic"
		"charm_bony_lure":
			return "bony"
		"charm_ink":
			return "cephalopod"
		_:
			return ""

static func _double_effect(multiplier: float) -> float:
	return max(0.0, 1.0 + ((multiplier - 1.0) * 2.0))
