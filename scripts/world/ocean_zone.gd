extends Node2D

var zone: int = 1
var player: CharacterBody2D = null
var greed_meter: GreedMeter = null
var current_fish: Dictionary = {}
var hazard_spawner := HazardSpawner.new()

func _ready() -> void:
	add_child(hazard_spawner)

func setup_zone(zone_number: int, controlled_player: CharacterBody2D, zone_greed_meter: GreedMeter) -> void:
	zone = zone_number
	player = controlled_player
	greed_meter = zone_greed_meter
	hazard_spawner.start_for_zone(zone, greed_meter)

func begin_fishing() -> void:
	if SceneManager.current_minigame != null:
		return
	if GameState.get_available_fish_slots() <= 0:
		SceneManager.show_notification("Inventory Full")
		return
	if not GameState.equipped_bait.is_empty():
		GameState.consume_bait()
	SceneManager.start_minigame("cast")
	var minigame := SceneManager.current_minigame
	if minigame == null:
		return
	minigame.cast_complete.connect(_on_cast_complete)
	minigame.cast_failed.connect(_on_cast_failed)

func _on_cast_complete(quality: String) -> void:
	SceneManager.end_minigame()
	TutorialManager.notify_action("cast_complete")
	ModifierStack.set_perfect_cast_bonus(quality == "perfect")
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	current_fish = SpawnTable.roll_fish(zone)
	if current_fish.is_empty():
		SceneManager.show_notification("Nothing Bit")
		return
	SceneManager.start_minigame("reel", {"fish": current_fish})
	var minigame := SceneManager.current_minigame
	if minigame:
		minigame.reel_complete.connect(_on_reel_complete)
		minigame.line_snapped.connect(_on_line_snapped)

func _on_cast_failed() -> void:
	SceneManager.show_notification("Line Tangled")

func _on_reel_complete(quality: float) -> void:
	current_fish["reel_quality"] = quality
	SceneManager.end_minigame()
	TutorialManager.notify_action("reel_complete")
	SceneManager.start_minigame("catch", {"fish": current_fish})
	var minigame := SceneManager.current_minigame
	if minigame:
		minigame.catch_success.connect(_on_catch_success)
		minigame.catch_failed.connect(_on_catch_failed)

func _on_line_snapped() -> void:
	SceneManager.end_minigame()
	TutorialManager.notify_action("reel_failed")
	current_fish.clear()
	SceneManager.show_notification("Line Snapped")

func _on_catch_success() -> void:
	SceneManager.end_minigame()
	ModifierStack.trigger_modifier(String(current_fish.get("modifier_effect", "")))
	ModifierStack.record_successful_catch(current_fish)
	if String(current_fish.get("id", "")) == "coelacanth":
		GameState.coelacanth_caught_today = true
	if GameState.add_fish(current_fish):
		_show_fish_popup(current_fish)
	TutorialManager.notify_action("catch_complete")
	current_fish.clear()

func _on_catch_failed() -> void:
	SceneManager.end_minigame()
	TutorialManager.notify_action("catch_failed")
	SceneManager.show_notification("Fish Escaped")
	current_fish.clear()

func _show_fish_popup(fish: Dictionary) -> void:
	var packed := load("res://scenes/ui/FishCaughtPopup.tscn") as PackedScene
	var main_root := get_tree().root.get_node_or_null("Main")
	if packed == null or main_root == null:
		SceneManager.show_notification("%s caught!" % fish.get("name", "Fish"))
		return
	var popup := packed.instantiate()
	main_root.add_child(popup)
	if popup.has_method("show_fish"):
		popup.show_fish(fish)
