extends CanvasLayer

signal reel_complete(quality: float)
signal line_snapped()

@onready var marker: ColorRect = $Marker
@onready var timer_label: Label = $TimerLabel
@onready var tutorial_label: Label = $TutorialLabel
@onready var blackout: ColorRect = $Blackout

var fish: Dictionary = {}
var _duration: float = 5.0
var _elapsed: float = 0.0
var _marker_value: float = 0.5
var _snap_time: float = 0.0
var _green_time: float = 0.0
var _yellow_time: float = 0.0
var _orange_time: float = 0.0
var _red_time: float = 0.0
var _rng := RandomNumberGenerator.new()
var _time_accumulator: float = 0.0

func _ready() -> void:
	_rng.randomize()
	blackout.visible = false
	tutorial_label.visible = false

func setup_context(context: Dictionary) -> void:
	fish = context.get("fish", {}).duplicate(true)
	_duration = clamp(lerp(5.0, 15.0, (float(fish.get("base_price", 4.0)) - 4.0) / 246.0), 5.0, 20.0)
	if fish.get("id", "") == "midnight_leviathan":
		_duration = 20.0
	_elapsed = 0.0
	_marker_value = 0.5
	_snap_time = 0.0
	_green_time = 0.0
	_yellow_time = 0.0
	_orange_time = 0.0
	_red_time = 0.0
	tutorial_label.visible = TutorialManager.current_step == TutorialManager.TutorialStep.REEL_TUTORIAL if TutorialManager != null else false
	tutorial_label.text = "Keep the marker in the green zone by holding the button. Don't let it snap!"

func _process(delta: float) -> void:
	if fish.is_empty():
		return
	_elapsed += delta
	_time_accumulator += delta
	var hold_up := Input.is_action_pressed("reel") or Input.is_action_pressed("ui_accept")
	var fish_speed := float(fish.get("reel_speed", 1.0))
	var amplitude := 0.35 + (0.05 * fish_speed)
	if int(fish.get("zone_caught", 1)) >= 3:
		amplitude += _rng.randf_range(-0.08, 0.08)
	var oscillation := sin(_time_accumulator * fish_speed * 4.0) * amplitude * delta
	var lift := 1.15 * delta if hold_up else -0.95 * delta
	_marker_value = clamp(_marker_value + lift + oscillation, 0.0, 1.0)
	_record_zone_time(delta)
	_update_marker_visual()
	timer_label.text = "%.1fs" % max(0.0, _duration - _elapsed)
	var snap_limit := 0.8 if GameState.active_charms.has("charm_frenzy") else 1.0
	if _marker_value >= 0.9:
		_snap_time += delta
		if _snap_time >= snap_limit:
			line_snapped.emit()
			return
	else:
		_snap_time = 0.0
	if _elapsed >= _duration:
		var quality := (_green_time * 1.0 + _yellow_time * 0.7 + _orange_time * 0.4 + _red_time * 0.1) / max(_duration, 0.001)
		reel_complete.emit(clamp(quality, 0.0, 1.0))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		setup_context({"fish": fish})

func blackout_for(seconds: float) -> void:
	blackout.visible = true
	await get_tree().create_timer(seconds).timeout
	blackout.visible = false

func _record_zone_time(delta: float) -> void:
	if _marker_value < 0.2:
		_red_time += delta
	elif _marker_value < 0.4:
		_orange_time += delta
	elif _marker_value < 0.7:
		_yellow_time += delta
	elif _marker_value < 0.9:
		_green_time += delta
	else:
		_red_time += delta

func _update_marker_visual() -> void:
	marker.anchor_top = 1.0 - _marker_value
