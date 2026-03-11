extends Control

# sell_confirm_popup.gd - Sell confirmation dialog

signal sell_confirmed(fish_id: String)
signal sell_cancelled()

@onready var fish_name: Label = $Panel/VBoxContainer/FishName
@onready var value_label: Label = $Panel/VBoxContainer/ValueLabel
@onready var confirm_button: Button = $Panel/VBoxContainer/HBoxContainer/ConfirmButton
@onready var cancel_button: Button = $Panel/VBoxContainer/HBoxContainer/CancelButton

var current_fish_id: String = ""

func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	hide()

func show_confirm(fish_id: String, fish_data: Resource):
	current_fish_id = fish_id
	fish_name.text = fish_data.name
	value_label.text = "Value: $%d" % fish_data.value
	show()

func _on_confirm_pressed():
	sell_confirmed.emit(current_fish_id)
	hide()

func _on_cancel_pressed():
	sell_cancelled.emit()
	hide()
