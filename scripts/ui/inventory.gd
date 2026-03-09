extends Control

# inventory.gd - Inventory UI controller

signal inventory_closed()

@onready var tabs: TabContainer = $Panel/VBoxContainer/Tabs
@onready var fish_grid: GridContainer = $Panel/VBoxContainer/Tabs/FishTab/FishGrid
@onready var items_grid: GridContainer = $Panel/VBoxContainer/Tabs/ItemsTab/ItemsGrid
@onready var materials_grid: GridContainer = $Panel/VBoxContainer/Tabs/MaterialsTab/MaterialsGrid
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	refresh_inventory()

func refresh_inventory():
	_clear_grids()
	_populate_fish()
	_populate_items()
	_populate_materials()

func _clear_grids():
	for child in fish_grid.get_children():
		child.queue_free()
	for child in items_grid.get_children():
		child.queue_free()
	for child in materials_grid.get_children():
		child.queue_free()

func _populate_fish():
	for fish_id in GameState.inventory.get("fish", {}):
		var count = GameState.inventory.fish[fish_id]
		_create_inventory_slot(fish_id, count, "fish")

func _populate_items():
	for item_type in ["rods", "baits", "charms"]:
		for item_id in GameState.inventory.get(item_type, {}):
			_create_inventory_slot(item_id, 1, "items")

func _populate_materials():
	for mat_id in GameState.inventory.get("materials", {}):
		var count = GameState.inventory.materials[mat_id]
		_create_inventory_slot(mat_id, count, "materials")

func _create_inventory_slot(item_id: String, count: int, tab: String):
	var label = Label.new()
	label.text = "%s x%d" % [item_id, count]
	
	match tab:
		"fish":
			fish_grid.add_child(label)
		"items":
			items_grid.add_child(label)
		"materials":
			materials_grid.add_child(label)

func _on_close_pressed():
	emit_signal("inventory_closed")
	hide()
