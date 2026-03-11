extends CanvasLayer

const FINN_DIALOGUE := "...Fine. A deal is a deal.\nYou're paid up. Get out of my shop.\n...Come back if you need another loan. I'll be here."

@onready var title_label: Label = $Panel/TitleLabel
@onready var stats_label: Label = $Panel/StatsLabel
@onready var dialogue_label: Label = $Panel/DialogueLabel
@onready var play_again_button: Button = $Panel/PlayAgainButton

func _ready() -> void:
	title_label.text = "DEBT CLEARED! You paid off Finn!"
	stats_label.text = "Day Cleared On: %d\nTotal Fish Caught: %d\nTotal Earned: $%.2f" % [
		GameState.current_day,
		GameState.total_fish_caught,
		GameState.total_earned
	]
	dialogue_label.text = FINN_DIALOGUE
	play_again_button.pressed.connect(_on_play_again_pressed)

func _on_play_again_pressed() -> void:
	SaveSystem.clear_save()
	GameState.reset_run()
	SceneManager.close_overlay()
	SceneManager.go_to_main_menu()
