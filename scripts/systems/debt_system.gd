extends Node

# debt_system.gd - Manages debt progression and interest

signal debt_paid(amount: int)
signal debt_increased(amount: int)
signal debt_cleared()

var current_debt: int = 1000
var daily_interest_rate: float = 0.1
var minimum_payment: int = 50

func _ready():
	current_debt = GameState.debt

func apply_daily_interest():
	var interest = int(current_debt * daily_interest_rate)
	current_debt += interest
	GameState.debt = current_debt
	emit_signal("debt_increased", interest)

func make_payment(amount: int):
	if amount > GameState.money:
		return false
	
	GameState.money -= amount
	current_debt -= amount
	GameState.debt = current_debt
	emit_signal("debt_paid", amount)
	
	if current_debt <= 0:
		current_debt = 0
		emit_signal("debt_cleared()
		return true
	
	return false

func get_debt() -> int:
	return current_debt

func get_minimum_payment() -> int:
	return min(minimum_payment, current_debt)

func get_interest_amount() -> int:
	return int(current_debt * daily_interest_rate)

func is_debt_cleared() -> bool:
	return current_debt <= 0
