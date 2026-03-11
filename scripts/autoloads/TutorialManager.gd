extends Node
class_name TutorialManager

enum TutorialStep {
	INTRO_DIALOGUE,
	SHOW_DEBT_METER,
	GO_TO_SHOP,
	BUY_BAIT,
	LEAVE_SHOP,
	GO_TO_BEACH,
	COLLECT_MATERIAL,
	GO_TO_DOCK,
	TALK_TO_FISHERMAN,
	DIVE_IN,
	CAST_TUTORIAL,
	REEL_TUTORIAL,
	CATCH_TUTORIAL,
	RETURN_TO_DOCK,
	FILET_TUTORIAL
}

const STEP_TEXT := {
	TutorialStep.INTRO_DIALOGUE: "You owe me $500. You have 7 days. Go fish.",
	TutorialStep.SHOW_DEBT_METER: "This is your debt. It goes up if you don't pay. Don't let it go up.",
	TutorialStep.GO_TO_SHOP: "Visit the shop to buy bait. You'll need it.",
	TutorialStep.BUY_BAIT: "Buy some bait. It makes fish more likely to bite.",
	TutorialStep.LEAVE_SHOP: "Good. Now go to the beach and look for materials.",
	TutorialStep.GO_TO_BEACH: "Head to the beach to find crafting materials.",
	TutorialStep.COLLECT_MATERIAL: "These materials wash up each morning. Collect them - they're used to craft charms later.",
	TutorialStep.GO_TO_DOCK: "Head to the dock. That's where the fishing starts.",
	TutorialStep.TALK_TO_FISHERMAN: "That old fisherman knows a thing or two. Have a word.",
	TutorialStep.DIVE_IN: "Jump in. The fish aren't going to catch themselves.",
	TutorialStep.CAST_TUTORIAL: "Hold the button to fill the bar. Release when it reaches the green zone.",
	TutorialStep.REEL_TUTORIAL: "Keep the marker in the green zone by holding the button. Don't let it snap!",
	TutorialStep.CATCH_TUTORIAL: "Keep your crosshair away from the red zone. Five seconds. You've got this.",
	TutorialStep.RETURN_TO_DOCK: "Good! Now head back to the dock. You can filet and sell there.",
	TutorialStep.FILET_TUTORIAL: "You can process your fish here to get a better price. Try it. Trace along the dotted line. Press the key when prompted."
}

const STEP_POSITIONS := {
	TutorialStep.INTRO_DIALOGUE: Vector2(640, 140),
	TutorialStep.SHOW_DEBT_METER: Vector2(1110, 90),
	TutorialStep.GO_TO_SHOP: Vector2(300, 260),
	TutorialStep.BUY_BAIT: Vector2(420, 200),
	TutorialStep.LEAVE_SHOP: Vector2(240, 640),
	TutorialStep.GO_TO_BEACH: Vector2(1180, 360),
	TutorialStep.COLLECT_MATERIAL: Vector2(500, 460),
	TutorialStep.GO_TO_DOCK: Vector2(1180, 360),
	TutorialStep.TALK_TO_FISHERMAN: Vector2(360, 280),
	TutorialStep.DIVE_IN: Vector2(960, 360),
	TutorialStep.CAST_TUTORIAL: Vector2(640, 160),
	TutorialStep.REEL_TUTORIAL: Vector2(1030, 220),
	TutorialStep.CATCH_TUTORIAL: Vector2(640, 560),
	TutorialStep.RETURN_TO_DOCK: Vector2(120, 80),
	TutorialStep.FILET_TUTORIAL: Vector2(620, 340)
}

var current_step: int = TutorialStep.INTRO_DIALOGUE
var _arrow: CanvasLayer = null
var _prompt: CanvasLayer = null

func _ready() -> void:
	if GameState.tutorial_completed:
		return
	current_step = TutorialStep.INTRO_DIALOGUE
	_show_step()

func advance_step() -> void:
	if GameState.tutorial_completed:
		return
	current_step += 1
	if current_step > TutorialStep.FILET_TUTORIAL:
		_complete_tutorial()
		return
	_show_step()

func notify_action(action: String) -> void:
	match current_step:
		TutorialStep.INTRO_DIALOGUE:
			if action == "intro_dismissed":
				advance_step()
		TutorialStep.SHOW_DEBT_METER:
			if action == "debt_seen":
				advance_step()
		TutorialStep.GO_TO_SHOP:
			if action == "shop_entered":
				advance_step()
		TutorialStep.BUY_BAIT:
			if action == "bait_bought":
				advance_step()
		TutorialStep.LEAVE_SHOP:
			if action == "shop_closed":
				advance_step()
		TutorialStep.GO_TO_BEACH:
			if action == "entered_beach":
				advance_step()
		TutorialStep.COLLECT_MATERIAL:
			if action == "material_collected":
				advance_step()
		TutorialStep.GO_TO_DOCK:
			if action == "entered_dock":
				advance_step()
		TutorialStep.TALK_TO_FISHERMAN:
			if action == "fisherman_talked":
				advance_step()
		TutorialStep.DIVE_IN:
			if action == "dove_in":
				advance_step()
		TutorialStep.CAST_TUTORIAL:
			if action == "cast_complete":
				advance_step()
		TutorialStep.REEL_TUTORIAL:
			if action == "reel_complete" or action == "reel_failed":
				advance_step()
				if action == "reel_failed":
					advance_step()
		TutorialStep.CATCH_TUTORIAL:
			if action == "catch_complete" or action == "catch_failed":
				advance_step()
		TutorialStep.RETURN_TO_DOCK:
			if action == "returned_to_dock":
				advance_step()
		TutorialStep.FILET_TUTORIAL:
			if action == "filet_complete" or action == "filet_skipped":
				_complete_tutorial()

func get_current_prompt() -> String:
	return STEP_TEXT.get(current_step, "")

func _complete_tutorial() -> void:
	GameState.tutorial_completed = true
	_hide_ui()

func _show_step() -> void:
	var main_root := get_tree().root.get_node_or_null("Main")
	if main_root == null:
		return
	if _arrow == null:
		var arrow_scene := load("res://scenes/ui/TutorialArrow.tscn") as PackedScene
		if arrow_scene:
			_arrow = arrow_scene.instantiate()
			main_root.add_child(_arrow)
	if _prompt == null:
		var prompt_scene := load("res://scenes/ui/TutorialPrompt.tscn") as PackedScene
		if prompt_scene:
			_prompt = prompt_scene.instantiate()
			main_root.add_child(_prompt)
	var position := STEP_POSITIONS.get(current_step, Vector2(640, 360))
	if _arrow and _arrow.has_method("point_to"):
		_arrow.point_to(position)
	if _prompt and _prompt.has_method("set_prompt"):
		_prompt.set_prompt(get_current_prompt(), position + Vector2(0, -48))

func _hide_ui() -> void:
	if _arrow != null and is_instance_valid(_arrow):
		_arrow.queue_free()
	if _prompt != null and is_instance_valid(_prompt):
		_prompt.queue_free()
	_arrow = null
	_prompt = null
