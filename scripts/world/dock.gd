extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hint_label: Label = $HintLabel
@onready var fisherman_marker: Marker2D = $FishermanMarker
@onready var dive_marker: Marker2D = $DiveMarker
@onready var filet_marker: Marker2D = $FiletMarker

func _ready() -> void:
	player.set_movement_mode("overworld")
	player.set_world_bounds(Rect2(48, 380, 1180, 260))
	player.global_position = Vector2(180, 560)

func _process(_delta: float) -> void:
	if player.global_position.x <= 40.0:
		SceneManager.go_to_beach()
		return
	if player.global_position.distance_to(fisherman_marker.global_position) <= 96.0:
		hint_label.text = "[E] Talk"
		if Input.is_action_just_pressed("interact"):
			var lines := FishermanNPC.get_lines(GameState.current_day)
			SceneManager.show_dialogue("Fisherman", lines, "fisherman_blip")
			TutorialManager.notify_action("fisherman_talked")
			return
	elif player.global_position.distance_to(dive_marker.global_position) <= 96.0:
		hint_label.text = "[E] Dive"
		if Input.is_action_just_pressed("interact"):
			TutorialManager.notify_action("dove_in")
			SceneManager.go_to_ocean(1)
			return
	elif player.global_position.distance_to(filet_marker.global_position) <= 96.0 and not GameState.fish_inventory.is_empty():
		hint_label.text = "[E] Filet First Fish"
		if Input.is_action_just_pressed("interact"):
			SceneManager.start_minigame("filet", {"fish": GameState.fish_inventory[0]})
			return
	else:
		hint_label.text = "Walk left to the beach"
