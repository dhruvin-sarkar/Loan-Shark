extends CanvasLayer

signal filet_complete(mult: float)

@onready var score_label: Label = $ScoreLabel
@onready var qte_label: Label = $QTELabel

var fish: Dictionary = {}
var _knife: KnifeData = null
var _score: float = 0.0
var _elapsed: float = 0.0
var _next_qte_at: float = 2.5
var _active_qte_key: String = ""
var _qte_deadline: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()

func setup_context(context: Dictionary) -> void:
	fish = context.get("fish", {}).duplicate(true)
	_knife = ItemDatabase.get_knife(GameState.equipped_knife)
	_score = 0.0
	_elapsed = 0.0
	_next_qte_at = _rng.randf_range(2.0, 4.0)
	_active_qte_key = ""
	_qte_deadline = 0.0
	qte_label.text = ""
	_update_score_label()

func _process(delta: float) -> void:
	if fish.is_empty() or _knife == null:
		return
	_elapsed += delta
	var mouse_pos := get_viewport().get_mouse_position()
	var board_center := Vector2(640, 360)
	var path_offset := abs(mouse_pos.y - board_center.y) + abs(mouse_pos.x - board_center.x * 0.8) * 0.15
	if path_offset <= float(_knife.sharpness_zone_px):
		_score += 14.0 * delta
	else:
		_score -= 9.0 * delta
	_score = clamp(_score, 0.0, 100.0)
	if _active_qte_key.is_empty() and _elapsed >= _next_qte_at:
		_start_qte()
	if not _active_qte_key.is_empty() and _elapsed > _qte_deadline:
		_score = max(0.0, _score - 12.0)
		_active_qte_key = ""
		qte_label.text = ""
	if _elapsed >= 8.0:
		_finish()
	_update_score_label()

func _input(event: InputEvent) -> void:
	if _active_qte_key.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_name := OS.get_keycode_string(event.keycode).to_upper()
		if key_name == _active_qte_key:
			_score = min(100.0, _score + 10.0)
			_active_qte_key = ""
			qte_label.text = ""

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		setup_context({"fish": fish})

func _start_qte() -> void:
	var keys := ["A", "S", "D", "F"]
	_active_qte_key = keys[_rng.randi_range(0, keys.size() - 1)]
	_qte_deadline = _elapsed + _knife.qte_window_seconds
	_next_qte_at = _elapsed + _rng.randf_range(2.0, 4.0)
	qte_label.text = _active_qte_key

func _finish() -> void:
	var multiplier := 0.5
	if _score >= 90.0:
		multiplier = 1.5
	elif _score >= 70.0:
		multiplier = 1.3
	elif _score >= 50.0:
		multiplier = 1.1
	elif _score >= 30.0:
		multiplier = 0.9
	multiplier = min(multiplier, _knife.max_filet_mult)
	if _score >= 90.0 and _knife.bonus_material_on_perfect:
		var materials := ItemDatabase.get_all_materials()
		if not materials.is_empty():
			var material := materials[_rng.randi_range(0, materials.size() - 1)]
			GameState.add_material(material.id, 1)
	filet_complete.emit(multiplier)

func _update_score_label() -> void:
	score_label.text = "Filet Score: %d%%" % int(round(_score))
