extends Control

# reel_minigame.gd - Reeling minigame controller

signal reel_completed(success: bool, fish_data: Resource)

var tension: float = 50.0
var fish_health: float = 100.0
var is_active: bool = false
var current_fish: Resource = null

@onready var tension_meter: ProgressBar = $TensionMeter
@onready var fish_health_bar: ProgressBar = $FishHealthBar
@onready var reel_button: Button = $ReelButton

func _ready():
	reel_button.button_down.connect(_start_reeling)
	reel_button.button_up.connect(_stop_reeling)

func _process(delta):
	if is_active:
		_update_tension(delta)
		_check_completion()

func _start_reeling():
	tension += 2.0

func _stop_reeling():
	tension = max(tension - 0.5, 0.0)

func _update_tension(delta):
	tension = clamp(tension, 0.0, 100.0)
	tension_meter.value = tension
	
	if tension > 90.0:
		# Line might break
		pass
	elif tension < 10.0:
		# Fish might escape
		fish_health += 0.5 * delta

func _check_completion():
	if fish_health <= 0.0:
		reel_completed.emit(true, current_fish)
		stop_minigame()
	elif fish_health >= 100.0:
		reel_completed.emit(false, null)
		stop_minigame()

var reel_duration: float = 5.0  # Calculated from fish base_price
var elapsed_time: float = 0.0

func _process(delta):
	if is_active:
		elapsed_time += delta
		_update_tension(delta)
		_check_completion()

func start_minigame(fish: Resource):
	current_fish = fish
	fish_health = 100.0
	tension = 50.0
	elapsed_time = 0.0
	
	# Calculate reel duration per GDD Section 30 Note 5
	var fish_data = FishDatabase.get_fish_data(fish.id if fish else "")
	if fish_data:
		var base_price = fish_data.get("base_price", 4)
		if fish_data.get("id", "") == "midnight_leviathan":
			reel_duration = 20.0  # Hardcoded for Leviathan
		else:
			# Formula: lerp(5.0, 15.0, (base_price - 4) / 246.0)
			reel_duration = lerpf(5.0, 15.0, (base_price - 4.0) / 246.0)
			reel_duration = clampf(reel_duration, 5.0, 20.0)
	else:
		reel_duration = 5.0
	
	is_active = true
	show()

func stop_minigame():
	is_active = false
	hide()
