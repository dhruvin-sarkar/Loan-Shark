extends Node

# FishingSystem.gd - Fishing mechanics controller

signal fishing_started()
signal fishing_ended()
signal fish_hooked(fish_data: Resource)
signal catch_attempt(result: bool)
signal fish_caught(fish_data: Resource, weight: float)

enum FishingState {
	IDLE,
	CASTING,
	WAITING,
	HOOKED,
	REELING,
	CATCHING
}

var current_state: int = FishingState.IDLE
var current_zone: String = "zone1"
var current_fish: Resource = null
var current_rod: Resource = null
var current_bait: Resource = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_fishing(zone: String, rod: Resource, bait: Resource):
	current_state = FishingState.CASTING
	current_zone = zone
	current_rod = rod
	current_bait = bait
	fishing_started.emit()

func cast_line():
	if current_state == FishingState.CASTING:
		current_state = FishingState.WAITING
		_wait_for_bite()

func _wait_for_bite():
	var wait_time = randf_range(2.0, 10.0)
	await get_tree().create_timer(wait_time).timeout
	
	if current_state == FishingState.WAITING:
		_hook_fish()

func _hook_fish():
	var spawn_table = FishDatabase.get_spawn_table(current_zone)
	if spawn_table:
		var fish_id = spawn_table.get_random_fish()
		current_fish = FishDatabase.get_fish_data(fish_id)
		
		if current_fish:
			current_state = FishingState.HOOKED
			fish_hooked.emit(current_fish)

func attempt_catch() -> bool:
	if current_state == FishingState.HOOKED and current_fish:
		var catch_chance = _calculate_catch_chance()
		var success = randf() < catch_chance
		
		catch_attempt.emit(success)
		
		if success:
			var weight = randf_range(current_fish.min_size, current_fish.max_size)
			fish_caught.emit(current_fish, weight)
			_end_fishing()
			return true
		else:
			_fish_escaped()
		
	return false

func _calculate_catch_chance() -> float:
	var base_chance = 0.5
	
	if current_rod:
		base_chance += current_rod.luck_bonus
	
	if current_bait:
		base_chance += current_bait.catch_bonus
	
	return min(base_chance, 0.95)

func _fish_escaped():
	current_fish = null
	current_state = FishingState.WAITING
	_wait_for_bite()

func _end_fishing():
	current_state = FishingState.IDLE
	current_fish = null
	fishing_ended.emit()

func cancel_fishing():
	_end_fishing()

func get_state() -> int:
	return current_state

func is_fishing() -> bool:
	return current_state != FishingState.IDLE
