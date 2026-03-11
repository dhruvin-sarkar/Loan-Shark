extends Node2D
class_name ForagingSpawner

const BEACH_BOUNDS := Rect2(160, 320, 960, 240)
const RARITY_WEIGHTS := {"common": 6, "uncommon": 3, "rare": 1}

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	GameState.day_changed.connect(_on_day_changed)
	spawn_for_day()

func spawn_for_day() -> void:
	_clear_spawned_nodes()
	var count := _rng.randi_range(8, 14)
	var available_materials := _get_spawnable_materials()
	if available_materials.is_empty():
		return
	for _index in range(count):
		var material := _pick_weighted_material(available_materials)
		if material == null:
			continue
		add_child(_create_material_node(material))

func _on_day_changed(_new_day: int) -> void:
	spawn_for_day()

func _get_spawnable_materials() -> Array[MaterialData]:
	var materials: Array[MaterialData] = []
	for material in ItemDatabase.get_all_materials():
		if material.night_only and not GameState.is_night():
			continue
		if GameState.current_day < material.day_unlock:
			continue
		if material.id == "shark_tooth" and GameState.current_day < 3:
			continue
		materials.append(material)
	return materials

func _pick_weighted_material(materials: Array[MaterialData]) -> MaterialData:
	var total := 0
	for material in materials:
		total += int(RARITY_WEIGHTS.get(material.rarity, 1))
	if total <= 0:
		return null
	var roll := _rng.randi_range(1, total)
	var cumulative := 0
	for material in materials:
		cumulative += int(RARITY_WEIGHTS.get(material.rarity, 1))
		if roll <= cumulative:
			return material
	return materials[0]

func _create_material_node(material: MaterialData) -> Area2D:
	var area := Area2D.new()
	area.name = material.id
	area.position = Vector2(
		_rng.randf_range(BEACH_BOUNDS.position.x, BEACH_BOUNDS.position.x + BEACH_BOUNDS.size.x),
		_rng.randf_range(BEACH_BOUNDS.position.y, BEACH_BOUNDS.position.y + BEACH_BOUNDS.size.y)
	)
	area.set_meta("material_id", material.id)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	area.add_child(shape)
	var label := Label.new()
	label.text = material.name
	label.position = Vector2(-40, -28)
	area.add_child(label)
	area.body_entered.connect(_on_material_collected.bind(area))
	return area

func _on_material_collected(body: Node, material_node: Area2D) -> void:
	if body == null or body.name != "Player":
		return
	var material_id := String(material_node.get_meta("material_id", ""))
	if material_id.is_empty():
		return
	GameState.add_material(material_id, 1)
	TutorialManager.notify_action("material_collected")
	material_node.queue_free()

func _clear_spawned_nodes() -> void:
	for child in get_children():
		child.queue_free()
