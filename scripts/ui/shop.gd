extends Control

# shop.gd - Shop UI controller

signal shop_closed()

@onready var tabs: TabContainer = $Panel/VBoxContainer/Tabs
@onready var buy_grid: GridContainer = $Panel/VBoxContainer/Tabs/BuyTab/BuyScrollContainer/BuyGrid
@onready var sell_grid: GridContainer = $Panel/VBoxContainer/Tabs/SellTab/SellScrollContainer/SellGrid
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	_populate_shop()

func _populate_shop():
	_populate_buy_tab()
	_populate_sell_tab()

func _populate_buy_tab():
	for rod_id in ItemDatabase.rods:
		var item_data = ItemDatabase.get_rod(rod_id)
		_create_shop_item(item_data, "buy")

func _populate_sell_tab():
	for fish_id in GameState.inventory.get("fish", {}):
		var fish_data = FishDatabase.get_fish_data(fish_id)
		if fish_data:
			_create_shop_item(fish_data, "sell")

func _create_shop_item(item_data: Resource, tab: String):
	var button = Button.new()
	button.text = "%s - $%d" % [item_data.name, item_data.value]
	button.pressed.connect(_on_item_pressed.bind(item_data, tab))
	
	if tab == "buy":
		buy_grid.add_child(button)
	else:
		sell_grid.add_child(button)

func _on_item_pressed(item_data: Resource, tab: String):
	if tab == "buy":
		_try_buy(item_data)
	else:
		_try_sell(item_data)

func _try_buy(item_data: Resource):
	if GameState.money >= item_data.value:
		GameState.money -= item_data.value
		GameState.add_item(item_data.id)

func _try_sell(item_data: Resource):
	GameState.money += item_data.value
	GameState.remove_item(item_data.id)

func _on_close_pressed():
	emit_signal("shop_closed")
	hide()
