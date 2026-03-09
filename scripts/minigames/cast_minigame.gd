extends Control

# cast_minigame.gd - Casting minigame controller

signal cast_completed(power: float, angle: float)

var power: float = 50.0
var angle: float = 0.0
var is_active: bool = false

@onready var power_meter: ProgressBar = $PowerMeter
@onready var angle_indicator: TextureRect = $AngleIndicator
@onready var cast_button: Button = $CastButton

func _ready():
	cast_button.pressed.connect(_on_cast_pressed)
	_start_power_cycle()

func _start_power_cycle():
	is_active = true
	while is_active:
		power = sin(Time.get_ticks_msec() / 500.0) * 50.0 + 50.0
		power_meter.value = power
		await get_tree().process_frame

func _on_cast_pressed():
	is_active = false
	cast_completed.emit(power, angle)
	hide()

func start_minigame():
	show()
	_start_power_cycle()

func stop_minigame():
	is_active = false
	hide()
