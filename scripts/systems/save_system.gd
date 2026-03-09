extends Node

# save_system.gd - Handles save/load functionality

const SAVE_PATH = "user://savegame.save"

signal game_saved()
signal game_loaded()

func save_game():
	var save_data = {
		"cash": GameState.cash,
		"debt": GameState.debt,
		"current_day": GameState.current_day,
		"fish_inventory": GameState.fish_inventory,
		"materials_inventory": GameState.materials_inventory,
		"current_scene": SceneManager.current_scene,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	game_saved.emit()

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	game_loaded.emit()
	
	return data

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func apply_save_data(data: Dictionary):
	if data.is_empty():
		return
	
	GameState.cash = data.get("cash", 0)
	GameState.debt = data.get("debt", 500.0)
	GameState.current_day = data.get("current_day", 1)
	GameState.fish_inventory = data.get("fish_inventory", [])
	GameState.materials_inventory = data.get("materials_inventory", {})
