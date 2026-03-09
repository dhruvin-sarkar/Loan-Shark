extends Control

# debt_pay_popup.gd - Debt payment dialog

signal payment_made(amount: int)
signal payment_cancelled()

@onready var debt_label: Label = $Panel/VBoxContainer/DebtLabel
@onready var money_label: Label = $Panel/VBoxContainer/MoneyLabel
@onready var amount_spinbox: SpinBox = $Panel/VBoxContainer/AmountSpinBox
@onready var pay_button: Button = $Panel/VBoxContainer/HBoxContainer/PayButton
@onready var cancel_button: Button = $Panel/VBoxContainer/HBoxContainer/CancelButton

func _ready():
	pay_button.pressed.connect(_on_pay_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	hide()

func show_payment():
	debt_label.text = "Current Debt: $%d" % GameState.debt
	money_label.text = "Your Money: $%d" % GameState.money
	amount_spinbox.max_value = min(GameState.money, GameState.debt)
	amount_spinbox.value = 0
	show()

func _on_pay_pressed():
	var amount = int(amount_spinbox.value)
	if amount > 0 and amount <= GameState.money:
		emit_signal("payment_made", amount)
	hide()

func _on_cancel_pressed():
	emit_signal("payment_cancelled")
	hide()
