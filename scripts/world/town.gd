extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hint_label: Label = $HintLabel
@onready var shop_marker: Marker2D = $ShopMarker

func _ready() -> void:
	player.set_movement_mode("overworld")
	player.set_world_bounds(Rect2(48, 380, 1180, 260))
	player.global_position = Vector2(160, 560)
	if GameState.current_day == 1 and not GameState.tutorial_completed and TutorialManager.current_step == TutorialManager.TutorialStep.INTRO_DIALOGUE:
		var lines := [
			"You owe me $500. You have 7 days. Go fish.",
			"Every day you don't pay, I add five percent.",
			"The fish are out there. Get to work."
		]
		SceneManager.show_dialogue("Finn", lines, "finn_blip")

func _process(_delta: float) -> void:
	if player.global_position.x >= 1220.0:
		SceneManager.go_to_beach()
		return
	if player.global_position.distance_to(shop_marker.global_position) <= 96.0:
		hint_label.text = "[E] Finn's Shop"
		if Input.is_action_just_pressed("interact"):
			SceneManager.show_shop()
			TutorialManager.notify_action("shop_entered")
	else:
		hint_label.text = "Walk right to the beach"
