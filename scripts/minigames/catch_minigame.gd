extends CanvasLayer

signal catch_success()
signal catch_failed()

@onready var danger_zone: ColorRect = $DangerZone
@onready var danger_zone_two: ColorRect = $DangerZone2
@onready var crosshair: ColorRect = $Crosshair
@onready var timer_label: Label = $TimerLabel
@onready var tutorial_label: Label = $TutorialLabel

var fish: Dictionary = {}
var _elapsed: float = 0.0
var _crosshair_x: float = 0.5
var _danger_x: float = 0.2
var _danger_velocity: float = 0.28
var _danger_two_x: float = 0.7
var _danger_two_velocity: float = -0.24
var _overlap_time: float = 0.0

func setup_context(context: Dictionary) -> void:
	fish = context.get("fish", {}).duplicate(true)
	_elapsed = 0.0
	_crosshair_x = 0.5
	_danger_x = 0.2
	_danger_velocity = 0.28
	_danger_two_x = 0.7
	_danger_two_velocity = -0.24
	_overlap_time = 0.0
	danger_zone_two.visible = int(fish.get("zone_caught", 1)) >= 3
	tutorial_label.visible = TutorialManager.current_step == TutorialManager.TutorialStep.CATCH_TUTORIAL if TutorialManager != null else false
	tutorial_label.text = "Keep your crosshair away from the red zone. Five seconds. You've got this."
	_update_visuals()

func _process(delta: float) -> void:
	if fish.is_empty():
		return
	_elapsed += delta
	var move_dir := Input.get_axis("move_left", "move_right")
	_crosshair_x = clamp(_crosshair_x + move_dir * 0.9 * delta, 0.05, 0.95)
	_update_danger_zone(delta)
	_update_visuals()
	if _is_overlapping():
		_overlap_time += delta
		if _overlap_time >= 0.5:
			catch_failed.emit()
			return
	if _elapsed >= 5.0:
		catch_success.emit()
		return
	timer_label.text = "%.1fs" % max(0.0, 5.0 - _elapsed)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		setup_context({"fish": fish})

func _update_danger_zone(delta: float) -> void:
	_danger_x += _danger_velocity * delta
	if _danger_x <= 0.0 or _danger_x >= 0.8:
		_danger_x = clamp(_danger_x, 0.0, 0.8)
		_danger_velocity *= -1.08
	if danger_zone_two.visible:
		_danger_two_x += _danger_two_velocity * delta
		if _danger_two_x <= 0.0 or _danger_two_x >= 0.88:
			_danger_two_x = clamp(_danger_two_x, 0.0, 0.88)
			_danger_two_velocity *= -1.05

func _update_visuals() -> void:
	crosshair.anchor_left = _crosshair_x
	crosshair.anchor_right = _crosshair_x + 0.02
	danger_zone.anchor_left = _danger_x
	danger_zone.anchor_right = _danger_x + 0.18
	danger_zone_two.anchor_left = _danger_two_x
	danger_zone_two.anchor_right = _danger_two_x + 0.10

func _is_overlapping() -> bool:
	var cross_left := _crosshair_x
	var cross_right := _crosshair_x + 0.02
	var danger_left := _danger_x
	var danger_right := _danger_x + 0.18
	var overlap := cross_left < danger_right and cross_right > danger_left
	if danger_zone_two.visible:
		var second_left := _danger_two_x
		var second_right := _danger_two_x + 0.10
		overlap = overlap or (cross_left < second_right and cross_right > second_left)
	return overlap
