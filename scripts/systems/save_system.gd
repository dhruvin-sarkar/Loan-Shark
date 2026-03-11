extends RefCounted
class_name SaveSystem

signal game_saved
signal game_loaded

const SAVE_PATH := "user://save.json"

static var _singleton: SaveSystem

static func _instance() -> SaveSystem:
	if _singleton == null:
		_singleton = SaveSystem.new()
	return _singleton

static func save_state(state: GameState) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(state.to_save_dictionary(), "\t"))
	_instance().game_saved.emit()

static func load_state(state: GameState) -> void:
	if not has_save():
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed := JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		state.apply_loaded_state(parsed)
		_instance().game_loaded.emit()

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
