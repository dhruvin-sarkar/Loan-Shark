extends Node
class_name HazardSpawner

signal hazard_spawned(hazard: Node)

const HAZARD_SCENES := {
	"jellyfish": "res://scenes/hazards/Jellyfish.tscn",
	"electric_eel": "res://scenes/hazards/ElectricEel.tscn",
	"shark": "res://scenes/hazards/Shark.tscn",
	"octopus": "res://scenes/hazards/Octopus.tscn",
	"turtle": "res://scenes/hazards/Turtle.tscn",
	"midnight_leviathan_hazard": "res://scenes/hazards/LeviathanHazard.tscn"
}

const ZONE_RULES := {
	1: {"chance": 0.05, "interval": 30.0, "types": ["jellyfish", "turtle"]},
	2: {"chance": 0.15, "interval": 20.0, "types": ["jellyfish", "electric_eel", "octopus", "turtle", "shark"]},
	3: {"chance": 0.30, "interval": 15.0, "types": ["electric_eel", "shark", "octopus", "midnight_leviathan_hazard"]},
	4: {"chance": 0.50, "interval": 10.0, "types": ["electric_eel", "shark", "octopus", "midnight_leviathan_hazard"]}
}

var current_zone: int = 1
var greed_meter: GreedMeter = null
var _timer := Timer.new()
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_timer.one_shot = false
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)

func start_for_zone(zone: int, zone_greed_meter: GreedMeter = null) -> void:
	current_zone = zone
	greed_meter = zone_greed_meter
	if greed_meter and not greed_meter.leviathan_forced.is_connected(_on_forced_leviathan):
		greed_meter.leviathan_forced.connect(_on_forced_leviathan)
	var rule: Dictionary = ZONE_RULES.get(zone, ZONE_RULES[1])
	_timer.wait_time = float(rule.get("interval", 30.0))
	_timer.start()

func stop_spawning() -> void:
	_timer.stop()

func _on_timeout() -> void:
	var rule: Dictionary = ZONE_RULES.get(current_zone, ZONE_RULES[1])
	var chance := float(rule.get("chance", 0.05))
	if greed_meter and (current_zone == 3 or current_zone == 4):
		chance *= greed_meter.get_hazard_multiplier()
	chance *= ModifierStack.get_hazard_multiplier()
	if _rng.randf() > min(chance, 1.0):
		return
	var types: Array = rule.get("types", [])
	if types.is_empty():
		return
	var hazard_type := String(types[_rng.randi_range(0, types.size() - 1)])
	await _spawn_hazard(hazard_type)

func _on_forced_leviathan() -> void:
	await _spawn_hazard("midnight_leviathan_hazard")

func _spawn_hazard(hazard_type: String) -> void:
	if hazard_type == "shark":
		AudioManager.play_sfx("presencebehind")
		var warning := _instantiate_scene("res://scenes/effects/SharkWarningVignette.tscn")
		if warning:
			add_child(warning)
		await get_tree().create_timer(3.0).timeout
	if hazard_type == "midnight_leviathan_hazard":
		var shake := _instantiate_scene("res://scenes/effects/LeviathanShake.tscn")
		if shake:
			add_child(shake)
		await get_tree().create_timer(0.6).timeout
	var scene_path := HAZARD_SCENES.get(hazard_type, "")
	if scene_path.is_empty():
		return
	var hazard := _instantiate_scene(scene_path)
	if hazard == null:
		return
	add_child(hazard)
	hazard_spawned.emit(hazard)

func _instantiate_scene(path: String) -> Node:
	if not ResourceLoader.exists(path):
		return null
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	return packed.instantiate()
