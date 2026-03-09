extends Node

# day_night_cycle.gd - Manages 600-second countdown timer per day (GDD v3.0 Section 30 Note 6)

signal time_changed(time_remaining: float, phase: String)
signal day_changed(day: int)
signal night_falling()
signal day_breaking()

var current_day: int = 1
var time_remaining: float = 600.0  # 10 minutes in seconds
var is_day_active: bool = false

const DAY_DURATION: float = 600.0  # 10 minutes per day

# Time phases (GDD Section 30 Note 6)
# Morning: 600-450s (first 25%)
# Afternoon: 450-300s (second 25%)
# Dusk: 300-150s (third 25%)
# Night: 150-0s (last 25%)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if is_day_active:
		_advance_time(delta)

func _advance_time(seconds: float):
	var old_phase = get_current_phase()
	time_remaining -= seconds
	
	if time_remaining <= 0:
		time_remaining = 0
		is_day_active = false
		_end_day()
		return
	
	var new_phase = get_current_phase()
	if old_phase != new_phase:
		if new_phase == "night":
			night_falling.emit()
		elif old_phase == "night":
			day_breaking.emit()
	
	time_changed.emit(time_remaining, new_phase)

func get_current_phase() -> String:
	if time_remaining > 450:
		return "morning"
	elif time_remaining > 300:
		return "afternoon"
	elif time_remaining > 150:
		return "dusk"
	else:
		return "night"

func is_night() -> bool:
	return time_remaining <= 150  # Last 25% of day is night

func is_day() -> bool:
	return not is_night()

func get_time_string() -> String:
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	return "%d:%02d" % [minutes, seconds]

func get_remaining_time() -> float:
	return time_remaining

func start_day():
	is_day_active = true
	time_remaining = DAY_DURATION

func _end_day():
	current_day += 1
	day_changed.emit(current_day)
	
	if current_day > 7:
		_game_over()

func _game_over():
	# Trigger game over state via GameState
	GameState.game_over.emit("time_out")

func reset():
	current_day = 1
	time_remaining = DAY_DURATION
	is_day_active = false
