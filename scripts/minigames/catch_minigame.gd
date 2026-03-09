extends Control

# catch_minigame.gd - Catch timing minigame controller

signal catch_completed(success: bool)

var indicator_position: float = 0.0
var target_range: Vector2 = Vector2(0.3, 0.7)
var time_remaining: float = 5.0
var is_active: bool = false

@onready var target_zone: TextureRect = $TargetZone
@onready var moving_indicator: TextureRect = $MovingIndicator
@onready var catch_button: Button = $CatchButton
@onready var timer_label: Label = $TimerLabel

func _ready():
	catch_button.pressed.connect(_on_catch_pressed)

func _process(delta):
	if is_active:
		_update_indicator(delta)
		_update_timer(delta)

func _update_indicator(delta):
	indicator_position = sin(Time.get_ticks_msec() / 300.0) * 0.5 + 0.5
	moving_indicator.position.x = lerp(0, get_rect().size.x, indicator_position)

func _update_timer(delta):
	time_remaining -= delta
	timer_label.text = "%.1f" % time_remaining
	
	if time_remaining <= 0.0:
		emit_signal("catch_completed", false)
		stop_minigame()

func _on_catch_pressed():
	if indicator_position >= target_range.x and indicator_position <= target_range.y:
		emit_signal("catch_completed", true)
	else:
		emit_signal("catch_completed", false)
	stop_minigame()

func start_minigame(duration: float = 5.0):
	time_remaining = duration
	is_active = true
	show()

func stop_minigame():
	is_active = false
	hide()
