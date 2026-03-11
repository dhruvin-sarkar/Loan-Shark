extends CanvasLayer

@onready var fish_list: ItemList = $Panel/FishList
@onready var sell_all_button: Button = $Panel/SellAllButton
@onready var filet_button: Button = $Panel/FiletButton
@onready var close_button: Button = $Panel/CloseButton

func _ready() -> void:
	_refresh_list()
	sell_all_button.pressed.connect(_on_sell_all_pressed)
	filet_button.pressed.connect(_on_filet_pressed)
	close_button.pressed.connect(SceneManager.close_overlay)
	GameState.inventory_changed.connect(_refresh_list)

func _refresh_list() -> void:
	fish_list.clear()
	for fish in GameState.fish_inventory:
		var quantity := int(fish.get("stack_count", 1))
		fish_list.add_item("%s x%d" % [fish.get("name", "Fish"), quantity])

func _on_sell_all_pressed() -> void:
	var total := GameState.sell_all_fish()
	SceneManager.show_notification("Sold for $%.2f" % total)
	_refresh_list()

func _on_filet_pressed() -> void:
	if GameState.fish_inventory.is_empty():
		return
	var selected := fish_list.get_selected_items()
	var fish_index := selected[0] if not selected.is_empty() else 0
	SceneManager.start_minigame("filet", {"fish": GameState.fish_inventory[fish_index], "fish_index": fish_index})
