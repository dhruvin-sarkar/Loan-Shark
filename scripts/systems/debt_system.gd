extends RefCounted
class_name DebtSystem

static func calculate_interest(debt: float) -> float:
	return debt * 1.05

static func get_debt_trajectory(current_debt: float, days_left: int) -> Array:
	var values: Array = []
	var projected := current_debt
	for _index in range(days_left):
		projected = round(calculate_interest(projected) * 100.0) / 100.0
		values.append(projected)
	return values
