extends Node

# foraging_spawner.gd - Spawns forageable materials in zones

signal material_spawned(material_instance: Node2D)

@export var spawn_rate: float = 60.0
@export var max_materials: int = 5

var active_materials: Array = []
var spawn_areas: Array = []

func _ready():
	_find_spawn_areas()
	_start_spawning()

func _find_spawn_areas():
	for child in get_parent().get_children():
		if child.is_in_group("forage_area"):
			spawn_areas.append(child)

func _start_spawning():
	while true:
		await get_tree().create_timer(spawn_rate).timeout
		if active_materials.size() < max_materials:
			_spawn_material()

func _spawn_material():
	if spawn_areas.is_empty():
		return
	
	var spawn_area = spawn_areas.pick_random()
	var material_id = _get_random_material()
	
	if material_id:
		var material_data = ItemDatabase.get_material(material_id)
		if material_data:
			# Create material pickup
			var material_node = Node2D.new()
			material_node.position = spawn_area.position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
			get_parent().add_child(material_node)
			active_materials.append(material_node)
			emit_signal("material_spawned", material_node)

func _get_random_material() -> String:
	var materials = ["mat_shell", "mat_coral", "mat_sea_glass", "mat_driftwood"]
	return materials.pick_random()

func collect_material(material_instance: Node2D):
	if material_instance in active_materials:
		active_materials.erase(material_instance)
		material_instance.queue_free()
