extends CanvasLayer

const REASON_TEXT := {
	"debt_spiral": "Your debt exceeded $1,000. Finn owns your boat now.",
	"time_out": "Seven days. Seven chances. All squandered."
}

@onready var reason_label: Label = $Panel/ReasonLabel
@onready var stats_label: Label = $Panel/StatsLabel
@onready var try_again_button: Button = $Panel/TryAgainButton

func _ready() -> void:
	try_again_button.pressed.connect(_on_try_again_pressed)

func setup_reason(reason: String) -> void:
	reason_label.text = REASON_TEXT.get(reason, "You lost.")
	stats_label.text = "Debt Remaining: $%.2f\nDays Used: %d\nTotal Earned: $%.2f" % [
		GameState.debt,
		min(GameState.current_day, 7),
		GameState.total_earned
	]

func _on_try_again_pressed() -> void:
	SaveSystem.clear_save()
	GameState.reset_run()
	SceneManager.close_overlay()
	SceneManager.go_to_main_menu()
