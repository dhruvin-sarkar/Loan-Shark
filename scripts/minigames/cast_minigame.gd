extends CanvasLayer

signal cast_complete(quality: String)
signal cast_failed()

@onready var fill_bar: ColorRect = $FillBar
@onready var sweet_spot: ColorRect = $SweetSpot
@onready var result_label: Label = $ResultLabel
@onready var tutorial_label: Label = $TutorialLabel

var _power: float = 0.0
var _holding: bool = false
var _overshot: bool = false
var _sweet_size: float = 0.2
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_reset_state()

func _process(delta: float) -> void:
	if _overshot:
		return
	if Input.is_action_just_pressed("cast") or Input.is_action_just_pressed("ui_accept"):
		_holding = true
	if Input.is_action_just_released("cast") or Input.is_action_just_released("ui_accept"):
		_release_cast()
	if _holding:
		_power += delta / 2.0
		if _power >= 1.0:
			_power = 1.0
			_trigger_overshot()
	_update_visuals()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_reset_state()

func _release_cast() -> void:
	if _overshot:
		return
	_holding = false
	var quality := "weak"
	var sweet_start := 1.0 - _sweet_size
	if _power >= sweet_start and _power <= 1.0:
		quality = "perfect"
	elif _power >= 0.5:
		quality = "good"
	ModifierStack.set_perfect_cast_bonus(quality == "perfect")
	result_label.text = quality.to_upper()
	cast_complete.emit(quality)

func _trigger_overshot() -> void:
	_overshot = true
	result_label.text = "OVERSHOT"
	cast_failed.emit()
	await get_tree().create_timer(1.0).timeout
	_reset_state()

func _reset_state() -> void:
	_power = 0.0
	_holding = false
	_overshot = false
	_sweet_size = 0.2 if GameState.current_day == 1 else _rng.randf_range(0.15, 0.30)
	result_label.text = ""
	tutorial_label.visible = TutorialManager.current_step == TutorialManager.TutorialStep.CAST_TUTORIAL if TutorialManager != null else false
	tutorial_label.text = "Hold the button to fill the bar. Release when it reaches the green zone."
	_update_visuals()

func _update_visuals() -> void:
	fill_bar.anchor_top = 1.0 - _power
	sweet_spot.anchor_top = 1.0 - _sweet_size
