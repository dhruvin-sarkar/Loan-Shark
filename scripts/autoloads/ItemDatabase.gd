extends Node
class_name ItemDatabase

const ROD_PATHS: Array[String] = [
	"res://resources/rod_data/rod_driftwood.tres",
	"res://resources/rod_data/rod_shell.tres",
	"res://resources/rod_data/rod_coral.tres",
	"res://resources/rod_data/rod_bone.tres",
	"res://resources/rod_data/rod_kelp.tres",
	"res://resources/rod_data/rod_deep.tres",
	"res://resources/rod_data/rod_fossil.tres",
	"res://resources/rod_data/rod_abyss.tres",
	"res://resources/rod_data/rod_leviathan.tres",
	"res://resources/rod_data/rod_oracle.tres"
]

const BAIT_PATHS: Array[String] = [
	"res://resources/bait_data/earthworm.tres",
	"res://resources/bait_data/maggot.tres",
	"res://resources/bait_data/insect.tres",
	"res://resources/bait_data/live_shrimp.tres",
	"res://resources/bait_data/sand_crab.tres",
	"res://resources/bait_data/smallfish.tres",
	"res://resources/bait_data/soft_plastic.tres",
	"res://resources/bait_data/jerkbait.tres",
	"res://resources/bait_data/jig.tres",
	"res://resources/bait_data/spinner.tres",
	"res://resources/bait_data/deep_sea_lure.tres",
	"res://resources/bait_data/luminous_lure.tres"
]

const KNIFE_PATHS: Array[String] = [
	"res://resources/knife_data/knife_rusty.tres",
	"res://resources/knife_data/knife_amateur.tres",
	"res://resources/knife_data/knife_pro.tres"
]

const MATERIAL_PATHS: Array[String] = [
	"res://resources/material_data/shell.tres",
	"res://resources/material_data/coral.tres",
	"res://resources/material_data/sea_glass.tres",
	"res://resources/material_data/driftwood.tres",
	"res://resources/material_data/algae.tres",
	"res://resources/material_data/night_kelp.tres",
	"res://resources/material_data/gold_sand.tres",
	"res://resources/material_data/deep_crystal.tres",
	"res://resources/material_data/echo_coral.tres",
	"res://resources/material_data/small_bone.tres",
	"res://resources/material_data/sand_crab.tres",
	"res://resources/material_data/ghost_fin.tres",
	"res://resources/material_data/shark_tooth.tres",
	"res://resources/material_data/ghost_crab_shell.tres"
]

const CHARM_PATHS: Array[String] = [
	"res://resources/charm_data/sell_charms/charm_shell.tres",
	"res://resources/charm_data/sell_charms/charm_coral.tres",
	"res://resources/charm_data/sell_charms/charm_deep.tres",
	"res://resources/charm_data/sell_charms/charm_tide.tres",
	"res://resources/charm_data/sell_charms/charm_gold.tres",
	"res://resources/charm_data/sell_charms/charm_night.tres",
	"res://resources/charm_data/sell_charms/charm_blood.tres",
	"res://resources/charm_data/sell_charms/charm_ink.tres",
	"res://resources/charm_data/spawn_charms/charm_eel_ward.tres",
	"res://resources/charm_data/spawn_charms/charm_siren.tres",
	"res://resources/charm_data/spawn_charms/charm_crustacean_call.tres",
	"res://resources/charm_data/spawn_charms/charm_bony_lure.tres",
	"res://resources/charm_data/spawn_charms/charm_depth_pulse.tres",
	"res://resources/charm_data/spawn_charms/charm_fortune_bait.tres",
	"res://resources/charm_data/spawn_charms/charm_calm_tide.tres",
	"res://resources/charm_data/spawn_charms/charm_frenzy.tres",
	"res://resources/charm_data/enchantment_charms/charm_tide_blessing.tres",
	"res://resources/charm_data/enchantment_charms/charm_deep_lure.tres",
	"res://resources/charm_data/enchantment_charms/charm_fortune_hook.tres",
	"res://resources/charm_data/enchantment_charms/charm_ghost_bait.tres",
	"res://resources/charm_data/enchantment_charms/charm_calm_waters.tres",
	"res://resources/charm_data/enchantment_charms/charm_blood_tide.tres",
	"res://resources/charm_data/enchantment_charms/charm_echo_line.tres",
	"res://resources/charm_data/enchantment_charms/charm_weighted_sink.tres"
]

var _rods: Dictionary = {}
var _baits: Dictionary = {}
var _knives: Dictionary = {}
var _charms: Dictionary = {}
var _materials: Dictionary = {}

func _ready() -> void:
	_rods = _load_resources(ROD_PATHS)
	_baits = _load_resources(BAIT_PATHS)
	_knives = _load_resources(KNIFE_PATHS)
	_charms = _load_resources(CHARM_PATHS)
	_materials = _load_resources(MATERIAL_PATHS)

func _load_resources(paths: Array[String]) -> Dictionary:
	var output: Dictionary = {}
	for path in paths:
		if not ResourceLoader.exists(path):
			push_error("Missing item resource: %s" % path)
			continue
		var resource := load(path)
		if resource == null:
			push_error("Invalid item resource: %s" % path)
			continue
		output[resource.id] = resource
	return output

func get_rod(id: String) -> RodData:
	return _rods.get(id, null)

func get_bait(id: String) -> BaitData:
	return _baits.get(id, null)

func get_knife(id: String) -> KnifeData:
	return _knives.get(id, null)

func get_charm(id: String) -> CharmData:
	return _charms.get(id, null)

func get_material(id: String) -> MaterialData:
	return _materials.get(id, null)

func get_all_charms() -> Array[CharmData]:
	var results: Array[CharmData] = []
	for charm in _charms.values():
		results.append(charm)
	return results

func get_all_rods() -> Array[RodData]:
	var results: Array[RodData] = []
	for rod in _rods.values():
		results.append(rod)
	return results

func get_all_baits() -> Array[BaitData]:
	var results: Array[BaitData] = []
	for bait in _baits.values():
		results.append(bait)
	return results

func get_all_knives() -> Array[KnifeData]:
	var results: Array[KnifeData] = []
	for knife in _knives.values():
		results.append(knife)
	return results

func get_all_materials() -> Array[MaterialData]:
	var results: Array[MaterialData] = []
	for material in _materials.values():
		results.append(material)
	return results

func can_access_zone(zone: int) -> bool:
	var rod := get_rod(GameState.equipped_rod)
	if zone == 1:
		return true
	if rod == null:
		return false
	if zone == 2:
		return rod.tier == "intermediate" or rod.tier == "pro"
	if zone == 3:
		return rod.tier == "pro"
	if zone == 4:
		return rod.tier == "pro" and (GameState.equipped_bait == "deep_sea_lure" or GameState.equipped_bait == "luminous_lure")
	return false
