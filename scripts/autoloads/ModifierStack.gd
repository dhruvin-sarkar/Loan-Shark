extends Node

# ModifierStack.gd - Handles spawn and sell multipliers from rods, baits, charms
# GDD v3.0 compliant - Includes modifier fish effects (Section 24)

signal modifiers_changed()

# Active modifier categories
var sell_multipliers: Dictionary = {}  # fish_family/category -> multiplier
var spawn_weights: Dictionary = {}     # fish_id -> weight multiplier
var hazard_reduction: float = 1.0
var reel_speed_modifier: float = 1.0
var catch_speed_modifier: float = 1.0

# === MODIFIER FISH EFFECTS (Section 24) ===
var goldfish_next_sale_active: bool = false  # True after catching goldfish_modifier
var sea_angel_charm_double_active: bool = false  # True after catching sea_angel
var sea_angel_duration_remaining: int = 0  # Days remaining for sea angel effect

# Fish families for affinity matching
const FISH_FAMILIES = {
	"pelagic": ["sardine", "needlefish", "lanternfish", "jellyfish"],
	"crustacean": ["crab", "rock_shrimp", "spiny_lobster", "ghost_crab", "rugose_crab", "abyssal_shrimp", "stone_crab"],
	"reef": ["clownfish", "seahorse", "trumpet_fish", "batfish"],
	"bony": ["bass", "pufferfish", "flounder", "perch", "snapper", "grouper", "oarfish", "coelacanth", "dragonfish_juv", "dragonfish_adult", "barreleye", "fangtooth", "frilled_shark", "goldfish_modifier"],
	"deep": ["anglerfish", "deep_angler", "viperfish", "gulper_eel", "sea_angel", "midnight_leviathan"],
	"eel": ["moray_small", "moray_large", "phantom_eel"],
	"cephalopod": ["octopus_small"]
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# === MODIFIER FISH EFFECTS ===

# Called when golden_koi is caught - sets up next sale bonus
func trigger_goldfish_effect():
	goldfish_next_sale_active = true
	modifiers_changed.emit()

# Called when sea_angel is caught - doubles charm effects for rest of day
func trigger_sea_angel_effect():
	sea_angel_charm_double_active = true
	sea_angel_duration_remaining = 1  # Lasts for current day only
	# Double all active charm effects
	for key in sell_multipliers:
		sell_multipliers[key] = _apply_sea_angel_doubler(sell_multipliers[key])
	for key in spawn_weights:
		spawn_weights[key] = _apply_sea_angel_doubler(spawn_weights[key])
	modifiers_changed.emit()

# Helper: Apply sea angel doubling with 1.5x cap for same-family bonuses
func _apply_sea_angel_doubler(value: float) -> float:
	# Cap at 1.5x for same-family bonuses, no cap for universal
	if value > 1.0:
		return minf(value * 2.0, 1.5) if value < 1.25 else value  # Already high, don't double
	return value

# Called when midnight_leviathan is caught - clears 20% of debt (debt *= 0.8)
func trigger_leviathan_effect():
	var debt_before = GameState.debt
	GameState.debt = GameState.debt * 0.8
	GameState.debt_changed.emit(GameState.debt)
	# Return the reduction amount for UI display
	return debt_before - GameState.debt

# Check if ghost crab night bonus applies (caught at night, sold at night)
func get_ghost_crab_bonus(fish: Dictionary, is_night: bool) -> float:
	if fish.get("id", "") == "ghost_crab" and fish.get("caught_at_night", false) and is_night:
		return 1.5  # 50% bonus
	return 1.0

# === SELL MULTIPLIERS ===

func apply_sell_multipliers(base_price: float, fish: Dictionary, is_night: bool = false) -> float:
	var final_price = base_price
	
	# Apply family-based multipliers
	var fish_family = fish.get("family", "")
	if fish_family != "" and sell_multipliers.has(fish_family):
		final_price *= sell_multipliers[fish_family]
	
	# Apply rarity-based multipliers
	var rarity = fish.get("rarity", "common")
	if sell_multipliers.has("rarity_" + rarity):
		final_price *= sell_multipliers["rarity_" + rarity]
	
	# Apply universal multiplier
	if sell_multipliers.has("all"):
		final_price *= sell_multipliers["all"]
	
	# Apply night-only fish multiplier if applicable
	if fish.get("night_only", false) and sell_multipliers.has("night_only"):
		final_price *= sell_multipliers["night_only"]
	
	# MODIFIER FISH: Ghost Crab night bonus
	var ghost_bonus = get_ghost_crab_bonus(fish, is_night)
	if ghost_bonus > 1.0:
		final_price *= ghost_bonus
	
	# MODIFIER FISH: Goldfish next sale bonus (applies to FIRST fish sold after goldfish)
	if goldfish_next_sale_active:
		final_price *= 1.5
		goldfish_next_sale_active = false  # One-time use
		modifiers_changed.emit()
	
	return final_price

func add_sell_multiplier(category: String, multiplier: float):
	if sell_multipliers.has(category):
		sell_multipliers[category] *= multiplier
	else:
		sell_multipliers[category] = multiplier
	modifiers_changed.emit()

func clear_sell_multipliers():
	sell_multipliers.clear()
	modifiers_changed.emit()

# === SPAWN WEIGHT MULTIPLIERS ===

func apply_spawn_multipliers(fish_id: String, base_weight: float) -> float:
	var final_weight = base_weight
	
	# Apply fish-specific multiplier
	if spawn_weights.has(fish_id):
		final_weight *= spawn_weights[fish_id]
	
	# Apply family multiplier
	var family = _get_fish_family(fish_id)
	if family != "" and spawn_weights.has("family_" + family):
		final_weight *= spawn_weights["family_" + family]
	
	# Apply rarity multiplier
	var fish_data = FishDatabase.get_fish_data(fish_id)
	if fish_data:
		var rarity = fish_data.get("rarity", "common")
		if spawn_weights.has("rarity_" + rarity):
			final_weight *= spawn_weights["rarity_" + rarity]
	
	# Apply universal spawn multiplier
	if spawn_weights.has("all"):
		final_weight *= spawn_weights["all"]
	
	return final_weight

func add_spawn_multiplier(category: String, multiplier: float):
	if spawn_weights.has(category):
		spawn_weights[category] *= multiplier
	else:
		spawn_weights[category] = multiplier
	modifiers_changed.emit()

func remove_spawn_multiplier(category: String):
	spawn_weights.erase(category)
	modifiers_changed.emit()

func clear_spawn_multipliers():
	spawn_weights.clear()
	modifiers_changed.emit()

# === HAZARD REDUCTION ===

func get_hazard_rate_multiplier() -> float:
	return hazard_reduction

func set_hazard_reduction(multiplier: float):
	hazard_reduction = multiplier

# === REEL/CATCH MODIFIERS ===

func get_reel_speed_modifier() -> float:
	return reel_speed_modifier

func set_reel_speed_modifier(value: float):
	reel_speed_modifier = value

func get_catch_speed_modifier() -> float:
	return catch_speed_modifier

func set_catch_speed_modifier(value: float):
	catch_speed_modifier = value

# === HELPER FUNCTIONS ===

func _get_fish_family(fish_id: String) -> String:
	for family in FISH_FAMILIES:
		if fish_id in FISH_FAMILIES[family]:
			return family
	return ""

# === ROD AFFINITY ===

func apply_rod_affinity(rod_id: String):
	# Rods have family affinities that modify spawn weights
	var rod_data = ItemDatabase.get_rod(rod_id)
	if not rod_data:
		return
	
	var affinity = rod_data.get("family_affinity", "")
	if affinity != "":
		add_spawn_multiplier("family_" + affinity, rod_data.get("affinity_bonus", 1.2))

# === BAIT MODIFIERS ===

func apply_bait_modifiers(bait_id: String):
	var bait_data = ItemDatabase.get_bait(bait_id)
	if not bait_data:
		return
	
	# Bait affects spawn rates
	var spawn_bonus = bait_data.get("spawn_bonus", 1.0)
	if spawn_bonus > 1.0:
		add_spawn_multiplier("all", spawn_bonus)
	
	# Some bait affects specific families
	var target_family = bait_data.get("target_family", "")
	if target_family != "":
		add_spawn_multiplier("family_" + target_family, bait_data.get("family_bonus", 1.3))

# === CHARM EFFECTS ===

func apply_charm_effects():
	# Clear existing modifiers first
	clear_sell_multipliers()
	clear_spawn_multipliers()
	hazard_reduction = 1.0
	
	# Apply active charms from GameState
	for charm_id in GameState.active_charms:
		var charm_data = ItemDatabase.get_charm(charm_id)
		if not charm_data:
			continue
		
		var charm_type = charm_data.get("charm_type", "")
		var effect_value = charm_data.get("effect_value", 0.0)
		var target = charm_data.get("target", "")
		
		match charm_type:
			"sell":
				if target != "":
					add_sell_multiplier(target, 1.0 + effect_value)
			"spawn":
				if target != "":
					add_spawn_multiplier(target, 1.0 + effect_value)
			"hazard":
				hazard_reduction *= (1.0 - effect_value)

# === DAILY RESET ===

func reset_daily():
	clear_sell_multipliers()
	clear_spawn_multipliers()
	hazard_reduction = 1.0
	reel_speed_modifier = 1.0
	catch_speed_modifier = 1.0
