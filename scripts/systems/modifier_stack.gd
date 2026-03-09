extends Node

# modifier_stack.gd - Manages active modifiers from charms and items

signal modifier_added(modifier_id: String)
signal modifier_removed(modifier_id: String)

var active_modifiers: Dictionary = {}

enum ModifierType {
	SELL_BONUS,
	SPAWN_RATE,
	CATCH_CHANCE,
	HAZARD_REDUCTION,
	DEPTH_BONUS,
	RARITY_BOOST
}

func add_modifier(modifier_id: String, type: int, value: float, duration: float = -1.0):
	active_modifiers[modifier_id] = {
		"type": type,
		"value": value,
		"duration": duration,
		"remaining": duration
	}
	emit_signal("modifier_added", modifier_id)

func remove_modifier(modifier_id: String):
	if active_modifiers.has(modifier_id):
		active_modifiers.erase(modifier_id)
		emit_signal("modifier_removed", modifier_id)

func get_modifier_value(type: int) -> float:
	var total: float = 0.0
	for mod_id in active_modifiers:
		if active_modifiers[mod_id]["type"] == type:
			total += active_modifiers[mod_id]["value"]
	return total

func _process(delta):
	var expired: Array = []
	for mod_id in active_modifiers:
		var mod = active_modifiers[mod_id]
		if mod["duration"] > 0:
			mod["remaining"] -= delta
			if mod["remaining"] <= 0:
				expired.append(mod_id)
	
	for mod_id in expired:
		remove_modifier(mod_id)

func has_modifier(modifier_id: String) -> bool:
	return active_modifiers.has(modifier_id)
