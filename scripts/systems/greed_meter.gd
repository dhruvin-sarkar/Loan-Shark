extends Node
class_name GreedMeter

signal leviathan_forced

var greed_level: float = 0.0
var current_zone: int = 1
var _shadow_warned: bool = false

func _process(delta: float) -> void:
	if current_zone == 3:
		greed_level += 0.005 * delta
	elif current_zone == 4:
		greed_level += 0.010 * delta
	else:
		return
	greed_level = clamp(greed_level, 0.0, 1.0)
	if greed_level >= 0.9 and not _shadow_warned:
		_shadow_warned = true
		AudioManager.play_sfx("shadow")
	if greed_level >= 1.0:
		force_leviathan_hazard_spawn()

func reset() -> void:
	greed_level = 0.0
	_shadow_warned = false

func get_hazard_multiplier() -> float:
	if greed_level < 0.3:
		return 1.0
	if greed_level < 0.6:
		return 1.5
	if greed_level < 0.9:
		return 2.5
	return 4.0

func force_leviathan_hazard_spawn() -> void:
	leviathan_forced.emit()
