extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hint_label: Label = $HintLabel
@onready var craft_marker: Marker2D = $CraftMarker
@onready var forage_container: Node2D = $ForageContainer

func _ready() -> void:
	player.set_movement_mode("overworld")
	player.set_world_bounds(Rect2(48, 380, 1180, 260))
	player.global_position = Vector2(200, 560)
	TutorialManager.notify_action("entered_beach")
	if forage_container.get_child_count() == 0:
		var spawner := ForagingSpawner.new()
		spawner.name = "ForagingSpawner"
		forage_container.add_child(spawner)

func _process(_delta: float) -> void:
	if player.global_position.x <= 40.0:
		SceneManager.go_to_town()
		return
	if player.global_position.x >= 1220.0:
		SceneManager.go_to_dock()
		return
	if player.global_position.distance_to(craft_marker.global_position) <= 96.0:
		hint_label.text = "[E] Craft Charms"
		if Input.is_action_just_pressed("interact"):
			SceneManager.show_crafting()
	else:
		hint_label.text = "Collect materials or walk to the dock"
