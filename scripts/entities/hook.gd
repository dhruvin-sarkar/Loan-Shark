extends Area2D

# hook.gd - Hook controller

signal fish_caught(fish: Node2D)
signal hook_landed()

var is_in_water: bool = false
var caught_fish: Node2D = null

@onready var detection_area: Area2D = $DetectionArea

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("fish") and not caught_fish:
		_catch_fish(body)

func _catch_fish(fish: Node2D):
	caught_fish = fish
	fish.get_caught(self)
	fish_caught.emit(fish)

func land():
	hook_landed.emit()
	if caught_fish:
		# Process caught fish
		pass

func set_in_water(value: bool):
	is_in_water = value

func has_fish() -> bool:
	return caught_fish != null
