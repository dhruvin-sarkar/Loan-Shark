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
			var lines := _get_fisherman_lines()
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

func _get_fisherman_lines() -> Array[String]:
	var lines_by_day := {
		1: [
			"New to these waters, eh? Let me tell you something.",
			"The shallow end will keep you alive. The deep end will make you rich.",
			"Start slow. Learn the zones. Don't get greedy."
		],
		2: ["Saw you come back with a decent haul yesterday.", "Stonefish are worth good money - nasty things, but valuable."],
		3: ["Below the kelp there are ruins.", "Good money for anyone brave enough. Or foolish enough."],
		4: ["Watch for the shark.", "Red vignette at the edge of your vision. That's your warning. Swim fast."],
		5: ["Zone Four tonight is your best shot if you've got the gear."],
		6: ["Leviathan's down there.", "Catch it and you'll write off half your trouble."],
		7: ["Last chance.", "The deep doesn't forgive hesitation."]
	}
	return lines_by_day.get(GameState.current_day, ["The sea is waiting."])
