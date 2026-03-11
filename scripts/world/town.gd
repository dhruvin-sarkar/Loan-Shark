extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hint_label: Label = $HintLabel
@onready var shop_marker: Marker2D = $ShopMarker

func _ready() -> void:
	player.set_movement_mode("overworld")
	player.set_world_bounds(Rect2(48, 380, 1180, 260))
	player.global_position = Vector2(160, 560)
	var is_start_of_day := GameState.time_remaining >= GameState.day_duration - 0.1
	if is_start_of_day and GameState.debt > 0.0:
		var paid_previous_day := GameState.current_day > 1 and GameState.days_without_payment == 0
		var lines := Finn.get_opening_lines(GameState.current_day, GameState.debt, paid_previous_day)
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
