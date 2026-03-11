extends Node

# fish_spawner.gd - Spawns fish based on zone spawn tables

signal fish_spawned(fish_instance: Node2D)
signal fish_despawned(fish_id: String)

@export var spawn_rate: float = 5.0
@export var max_fish: int = 10

var active_fish: Array = []
var spawn_points: Array = []
var current_zone: String = "zone1"

func _ready():
	_find_spawn_points()
	_start_spawning()

func _find_spawn_points():
	for child in get_parent().get_children():
		if child.is_in_group("fish_spawn_point"):
			spawn_points.append(child)

func _start_spawning():
	while active_fish.size() < max_fish:
		await get_tree().create_timer(spawn_rate).timeout
		_spawn_fish()

func _spawn_fish():
	if spawn_points.is_empty():
		return
	
	var spawn_point = spawn_points.pick_random()
	var fish_data = FishDatabase.get_random_fish(current_zone)
	
	if fish_data:
		var fish_scene = load("res://scenes/entities/fish/FishBase.tscn")
		var fish_instance = fish_scene.instantiate()
		fish_instance.fish_data = fish_data
		fish_instance.position = spawn_point.position
		get_parent().add_child(fish_instance)
		active_fish.append(fish_instance)
		fish_spawned.emit(fish_instance)

func despawn_fish(fish_instance: Node2D):
	if fish_instance in active_fish:
		active_fish.erase(fish_instance)
		fish_despawned.emit(fish_instance.fish_data.name)
		fish_instance.queue_free()

func set_zone(zone: String):
	current_zone = zone
