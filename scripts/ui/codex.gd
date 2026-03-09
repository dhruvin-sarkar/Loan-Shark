extends Control

# codex.gd - Fish codex UI controller

signal codex_closed()

@onready var fish_list: ItemList = $Panel/HSplitContainer/FishList
@onready var fish_details: RichTextLabel = $Panel/HSplitContainer/FishDetails
@onready var close_button: Button = $Panel/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	fish_list.item_selected.connect(_on_fish_selected)
	_populate_codex()

func _populate_codex():
	fish_list.clear()
	
	for fish_id in FishDatabase.fish_data:
		var fish_data = FishDatabase.get_fish_data(fish_id)
		if fish_data:
			var index = fish_list.add_item(fish_data.name)
			fish_list.set_item_metadata(index, fish_id)

func _on_fish_selected(index: int):
	var fish_id = fish_list.get_item_metadata(index)
	var fish_data = FishDatabase.get_fish_data(fish_id)
	
	if fish_data:
		_display_fish_details(fish_data)

func _display_fish_details(fish_data: Resource):
	var details = "[b]%s[/b]\n\n" % fish_data.name
	details += "Rarity: %s\n" % fish_data.rarity
	details += "Zone: %s\n" % fish_data.zone
	details += "Base Value: $%d\n\n" % fish_data.value
	details += fish_data.description
	
	fish_details.text = details

func _on_close_pressed():
	emit_signal("codex_closed")
	hide()
