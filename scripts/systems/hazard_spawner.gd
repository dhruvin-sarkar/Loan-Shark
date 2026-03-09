extends Node

# hazard_spawner.gd - Spawns hazards in ocean zones (GDD v3.0 compliant)

signal hazard_spawned(hazard_instance: Node2D)
signal hazard_warning(hazard_type: String)

@export var spawn_rate: float = 30.0
@export var max_hazards: int = 3
@export var warning_time: float = 3.0
@export var current_zone: int = 1

var active_hazards: Array = []

# Zone-specific hazard types and rates (GDD Section 13)
# Spawn rates: Z1: 5% per 30s, Z2: 15% per 20s, Z3: 30% per 15s, Z4: 50% per 10s
var zone_hazard_config: Dictionary = {
	1: {
		"types": ["jellyfish", "turtle"],
		"spawn_interval": 30.0,
		"spawn_chance": 0.05,
		"max_hazards": 2
	},
	2: {
		"types": ["jellyfish", "electric_eel", "octopus", "turtle"],
		"spawn_interval": 20.0,
		"spawn_chance": 0.15,
		"max_hazards": 3
	},
	3: {
		"types": ["shark", "electric_eel", "octopus"],
		"spawn_interval": 15.0,
		"spawn_chance": 0.30,
		"max_hazards": 4
	},
	4: {
		"types": ["shark", "electric_eel", "midnight_leviathan"],
		"spawn_interval": 10.0,
		"spawn_chance": 0.50,
		"max_hazards": 5
	}
}

func _ready():
	_start_spawning()

func set_zone(zone: int):
	current_zone = zone
	var config = zone_hazard_config.get(zone, zone_hazard_config[1])
	spawn_rate = config.spawn_interval
	max_hazards = config.max_hazards

func _start_spawning():
	while true:
		await get_tree().create_timer(spawn_rate).timeout
		if active_hazards.size() < max_hazards:
			_spawn_hazard()

func _spawn_hazard():
	var config = zone_hazard_config.get(current_zone, zone_hazard_config[1])
	
	# Check spawn chance per GDD Section 13
	if randf() > config.spawn_chance:
		return
	
	var hazard_type = config.types.pick_random()
	var hazard_scene_path = _get_hazard_scene_path(hazard_type)
	
	if ResourceLoader.exists(hazard_scene_path):
		# Emit warning first
		hazard_warning.emit(hazard_type)
		await get_tree().create_timer(warning_time).timeout
		
		var hazard_scene = load(hazard_scene_path)
		var hazard_instance = hazard_scene.instantiate()
		
		# Spawn at edge of screen
		hazard_instance.position = _get_spawn_position()
		get_parent().add_child(hazard_instance)
		active_hazards.append(hazard_instance)
		hazard_spawned.emit(hazard_instance)

func _get_hazard_scene_path(hazard_type: String) -> String:
	# Explicit scene paths per GDD Section 13
	match hazard_type:
		"jellyfish": return "res://scenes/hazards/Jellyfish.tscn"
		"electric_eel": return "res://scenes/hazards/ElectricEel.tscn"
		"shark": return "res://scenes/hazards/Shark.tscn"
		"octopus": return "res://scenes/hazards/Octopus.tscn"
		"turtle": return "res://scenes/hazards/Turtle.tscn"
		"midnight_leviathan": return "res://scenes/hazards/LeviathanHazard.tscn"
		_: return ""

func _get_spawn_position() -> Vector2:
	var viewport = get_viewport().get_visible_rect()
	var side = randi() % 4
	
	match side:
		0: return Vector2(0, randf_range(0, viewport.size.y))
		1: return Vector2(viewport.size.x, randf_range(0, viewport.size.y))
		2: return Vector2(randf_range(0, viewport.size.x), 0)
		3: return Vector2(randf_range(0, viewport.size.x), viewport.size.y)
	return Vector2.ZERO

func remove_hazard(hazard_instance: Node2D):
	if hazard_instance in active_hazards:
		active_hazards.erase(hazard_instance)
		hazard_instance.queue_free()
