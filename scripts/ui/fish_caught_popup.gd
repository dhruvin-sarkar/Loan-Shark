extends Control

# fish_caught_popup.gd - Fish caught notification

signal popup_closed()

@onready var fish_icon: TextureRect = $Panel/VBoxContainer/FishIcon
@onready var fish_name: Label = $Panel/VBoxContainer/FishName
@onready var fish_weight: Label = $Panel/VBoxContainer/FishWeight
@onready var fish_value: Label = $Panel/VBoxContainer/FishValue
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)

func show_fish(fish_data: Resource, weight: float):
	fish_name.text = fish_data.name
	fish_weight.text = "%.1f kg" % weight
	
	var value = int(fish_data.value * (weight / fish_data.avg_weight))
	fish_value.text = "$%d" % value
	
	if fish_data.texture:
		fish_icon.texture = fish_data.texture
	
	show()

func _on_close_pressed():
	emit_signal("popup_closed")
	hide()
