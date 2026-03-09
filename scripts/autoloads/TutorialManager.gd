extends Node

# TutorialManager.gd - Manages Day 1 tutorial steps

signal tutorial_step_completed(step: int)
signal tutorial_started()
signal tutorial_finished()

enum TutorialStep {
	NONE,
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
	FILET_TUTORIAL,
	COMPLETE
}

var current_step: int = TutorialStep.NONE
var tutorial_active: bool = false
var tutorial_day: int = 1

func _ready():
	if GameState.current_day == 1 and not GameState.tutorial_completed:
		start_tutorial()

func start_tutorial():
	tutorial_active = true
	current_step = TutorialStep.INTRO_DIALOGUE
	tutorial_started.emit()

func advance_step():
	if not tutorial_active:
		return
	
	current_step += 1
	tutorial_step_completed.emit(current_step)
	
	if current_step >= TutorialStep.COMPLETE:
		complete_tutorial()

func complete_tutorial():
	tutorial_active = false
	current_step = TutorialStep.COMPLETE
	GameState.tutorial_completed = true
	tutorial_finished.emit()

func get_current_step() -> int:
	return current_step

func is_tutorial_active() -> bool:
	return tutorial_active

func get_step_description() -> String:
	match current_step:
		TutorialStep.INTRO_DIALOGUE:
			return "You owe me $500. You have 7 days. Go fish."
		TutorialStep.SHOW_DEBT_METER:
			return "This is your debt. It goes up if you don't pay. Don't let it go up."
		TutorialStep.GO_TO_SHOP:
			return "Visit the shop to buy bait. You'll need it."
		TutorialStep.BUY_BAIT:
			return "Buy some bait. It makes fish more likely to bite."
		TutorialStep.LEAVE_SHOP:
			return "Good. Now go to the beach and look for materials."
		TutorialStep.GO_TO_BEACH:
			return "Head to the beach to find crafting materials."
		TutorialStep.COLLECT_MATERIAL:
			return "These materials wash up each morning. Collect them — they're used to craft charms later."
		TutorialStep.GO_TO_DOCK:
			return "Head to the dock. That's where the fishing starts."
		TutorialStep.TALK_TO_FISHERMAN:
			return "That old fisherman knows a thing or two. Have a word."
		TutorialStep.DIVE_IN:
			return "Jump in. The fish aren't going to catch themselves."
		TutorialStep.CAST_TUTORIAL:
			return "Hold the button to fill the bar. Release when it reaches the green zone."
		TutorialStep.REEL_TUTORIAL:
			return "Keep the marker in the green zone by holding the button. Don't let it snap!"
		TutorialStep.CATCH_TUTORIAL:
			return "Keep your crosshair away from the red zone. Five seconds. You've got this."
		TutorialStep.RETURN_TO_DOCK:
			return "Good! Now head back to the dock. You can filet and sell there."
		TutorialStep.FILET_TUTORIAL:
			return "You can process your fish here to get a better price. Trace along the dotted line. Press the key when prompted."
		_:
			return ""
