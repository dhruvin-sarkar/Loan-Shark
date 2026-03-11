extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var zone_holder: Node2D = $ZoneHolder
@onready var hint_label: Label = $HintLabel

var current_zone: int = 1
var current_zone_node: Node = null
var greed_meter := GreedMeter.new()

func _ready() -> void:
	add_child(greed_meter)
	player.set_movement_mode("ocean")
	player.set_world_bounds(Rect2(48, 48, 1180, 620))
	current_zone = SceneManager.pending_ocean_zone
	_load_zone(current_zone)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cast") and current_zone_node and current_zone_node.has_method("begin_fishing"):
		current_zone_node.begin_fishing()
	if player.global_position.y <= 60.0 and Input.is_action_pressed("move_up"):
		if current_zone > 1:
			_load_zone(current_zone - 1)
			player.global_position.y = 620.0
		else:
			greed_meter.reset()
			TutorialManager.notify_action("returned_to_dock")
			SceneManager.go_to_dock()
			return
	if player.global_position.y >= 660.0 and Input.is_action_pressed("move_down"):
		var next_zone := current_zone + 1
		if next_zone <= 4 and ItemDatabase.can_access_zone(next_zone):
			_load_zone(next_zone)
			player.global_position.y = 100.0
		elif next_zone <= 4:
			SceneManager.show_notification("Current Too Strong")
	hint_label.text = "Cast with SPACE. Swim up to surface."

func _load_zone(zone: int) -> void:
	current_zone = zone
	GameState.current_zone = zone
	greed_meter.current_zone = zone
	if current_zone_node and is_instance_valid(current_zone_node):
		current_zone_node.queue_free()
	var path := "res://scenes/world/ocean/OceanZone%d_%s.tscn" % [zone, ["", "Shallows", "KelpForest", "SunkenRuins", "BiolumDeep"][zone]]
	var packed := load(path) as PackedScene
	if packed == null:
		return
	current_zone_node = packed.instantiate()
	zone_holder.add_child(current_zone_node)
	if current_zone_node.has_method("setup_zone"):
		current_zone_node.setup_zone(zone, player, greed_meter)
	AudioManager.play_music("ocean_z%d" % zone)
