extends CanvasLayer

@onready var day_label: Label = $Panel/DayLabel
@onready var fish_list_label: Label = $Panel/FishListLabel
@onready var earned_label: Label = $Panel/EarnedLabel
@onready var paid_label: Label = $Panel/PaidLabel
@onready var interest_label: Label = $Panel/InterestLabel
@onready var debt_label: Label = $Panel/DebtLabel
@onready var days_remaining_label: Label = $Panel/DaysRemainingLabel
@onready var next_day_button: Button = $Panel/NextDayButton

func _ready() -> void:
	next_day_button.pressed.connect(_on_next_day_pressed)

func setup_summary(summary: Dictionary) -> void:
	day_label.text = "Day %d Summary" % int(summary.get("day", GameState.current_day - 1))
	var lines: Array[String] = []
	for fish in summary.get("fish_caught", []):
		lines.append("%s  $%.2f" % [fish.get("name", "Fish"), float(fish.get("base_price", 0.0))])
	if lines.is_empty():
		lines.append("No fish caught.")
	fish_list_label.text = "\n".join(lines)
	earned_label.text = "Total Earned Today: $%.2f" % float(summary.get("total_earned_today", 0.0))
	paid_label.text = "Debt Paid Today: $%.2f" % float(summary.get("debt_paid_today", 0.0))
	interest_label.text = "Interest Added: $%.2f" % float(summary.get("interest_added", 0.0))
	debt_label.text = "New Debt Total: $%.2f" % float(summary.get("new_debt_total", GameState.debt))
	days_remaining_label.text = "Days Remaining: %d" % int(summary.get("days_remaining", 0))

func _on_next_day_pressed() -> void:
	SceneManager.close_overlay()
	if GameState.current_day <= 7 and GameState.debt > 0.0:
		GameState.begin_next_day()
		SceneManager.go_to_town()
