extends Node
class_name DayNightCycle

signal phase_changed(phase: String)

var _last_phase: String = ""

func _ready() -> void:
	_last_phase = get_phase()

func _process(delta: float) -> void:
	if not GameState.is_day_active:
		return
	GameState.time_remaining = max(0.0, GameState.time_remaining - delta)
	var phase := get_phase()
	if phase != _last_phase:
		_last_phase = phase
		phase_changed.emit(phase)
	if GameState.time_remaining <= 0.0:
		GameState.time_remaining = 0.0
		GameState.is_day_active = false
		GameState.end_of_day()

func get_phase() -> String:
	if GameState.time_remaining > 450.0:
		return "morning"
	if GameState.time_remaining > 300.0:
		return "afternoon"
	if GameState.time_remaining > 150.0:
		return "dusk"
	return "night"
