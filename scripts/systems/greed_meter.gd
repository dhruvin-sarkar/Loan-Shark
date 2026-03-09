extends Node

# greed_meter.gd - Greed meter system for deep zone pressure (GDD v3.0 Section 25)
# P2 feature - Implement only after P0 and P1 complete

signal greed_level_changed(level: float)
signal greed_max_triggered()

@export var enabled: bool = true

var greed_level: float = 0.0  # 0.0 to 1.0
var current_zone: int = 1
var is_in_ocean: bool = false

# Greed accumulation rates per zone (per second)
const ZONE_GREED_RATES = {
	3: 0.005,  # Zone 3: fills in ~200 seconds
	4: 0.010   # Zone 4: fills in ~100 seconds
}

# Hazard rate multipliers at different greed levels
const GREED_HAZARD_MULTIPLIERS = [
	{"threshold": 0.0, "multiplier": 1.0},   # Normal
	{"threshold": 0.3, "multiplier": 1.5},   # Slightly elevated
	{"threshold": 0.6, "multiplier": 2.5},   # High - Shadow.ogg starts
	{"threshold": 0.9, "multiplier": 4.0}    # Critical - red vignette
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if not enabled or not is_in_ocean:
		return
	
	# Only accumulate in Zone 3 and 4
	if current_zone >= 3 and ZONE_GREED_RATES.has(current_zone):
		var rate = ZONE_GREED_RATES[current_zone]
		greed_level = minf(greed_level + (rate * delta), 1.0)
		emit_signal("greed_level_changed", greed_level)
		
		# Check for max greed - trigger Leviathan hazard
		if greed_level >= 1.0:
			emit_signal("greed_max_triggered")

func set_zone(zone: int):
	current_zone = zone

func enter_ocean():
	is_in_ocean = true

func exit_ocean():
	is_in_ocean = false
	reset_greed()

func reset_greed():
	greed_level = 0.0
	emit_signal("greed_level_changed", greed_level)

func get_hazard_multiplier() -> float:
	for i in range(GREED_HAZARD_MULTIPLIERS.size() - 1, -1, -1):
		if greed_level >= GREED_HAZARD_MULTIPLIERS[i].threshold:
			return GREED_HAZARD_MULTIPLIERS[i].multiplier
	return 1.0

func get_greed_level() -> float:
	return greed_level

func is_greed_critical() -> bool:
	return greed_level >= 0.9

func is_greed_high() -> bool:
	return greed_level >= 0.6

func should_play_shadow_audio() -> bool:
	return greed_level >= 0.6
