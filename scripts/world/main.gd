extends Node

@onready var day_night_cycle: DayNightCycle = $DayNightCycle
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	_ensure_input_map()
	day_night_cycle.phase_changed.connect(_on_phase_changed)
	call_deferred("_open_main_menu")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if SceneManager.current_overlay != null:
			SceneManager.close_overlay()

func _open_main_menu() -> void:
	SceneManager.go_to_main_menu()

func _on_phase_changed(phase: String) -> void:
	if hud and hud.has_method("update_day_phase"):
		hud.update_day_phase(phase)

func _ensure_input_map() -> void:
	_add_key_action("cast", KEY_SPACE)
	_add_key_action("reel", KEY_SPACE)
	_add_key_action("interact", KEY_E)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_left", KEY_LEFT)
	_add_key_action("move_right", KEY_D)
	_add_key_action("move_right", KEY_RIGHT)
	_add_key_action("move_up", KEY_W)
	_add_key_action("move_up", KEY_UP)
	_add_key_action("move_down", KEY_S)
	_add_key_action("move_down", KEY_DOWN)
	_add_key_action("pause", KEY_ESCAPE)
	_add_key_action("ui_accept", KEY_ENTER)
	_add_key_action("ui_accept", KEY_SPACE)

func _add_key_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return
	var input_event := InputEventKey.new()
	input_event.keycode = keycode
	InputMap.action_add_event(action, input_event)
