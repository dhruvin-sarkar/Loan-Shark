extends Control

# day_end_summary.gd - End of day summary screen

signal continue_pressed()

@onready var fish_caught_label: Label = $Panel/VBoxContainer/FishCaughtLabel
@onready var earnings_label: Label = $Panel/VBoxContainer/EarningsLabel
@onready var debt_remaining_label: Label = $Panel/VBoxContainer/DebtRemainingLabel
@onready var days_left_label: Label = $Panel/VBoxContainer/DaysLeftLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)

func show_summary(fish_count: int, earnings: int, debt: int, days_left: int):
	fish_caught_label.text = "Fish Caught: %d" % fish_count
	earnings_label.text = "Total Earnings: $%d" % earnings
	debt_remaining_label.text = "Debt Remaining: $%d" % debt
	days_left_label.text = "Days Left: %d" % days_left
	show()

func _on_continue_pressed():
	emit_signal("continue_pressed")
	hide()
