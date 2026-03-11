extends CanvasLayer

@onready var rods_list: ItemList = $Panel/RodsList
@onready var baits_list: ItemList = $Panel/BaitsList
@onready var knives_list: ItemList = $Panel/KnivesList
@onready var info_label: Label = $Panel/InfoLabel
@onready var finn_line_label: Label = $Panel/FinnLineLabel
@onready var buy_button: Button = $Panel/BuyButton
@onready var debt_amount: SpinBox = $Panel/DebtAmountSpinBox
@onready var pay_debt_button: Button = $Panel/PayDebtButton
@onready var close_button: Button = $Panel/CloseButton

var _selected_type: String = "rod"
var _selected_id: String = ""

func _ready() -> void:
	_populate_lists()
	rods_list.item_selected.connect(_on_rod_selected)
	baits_list.item_selected.connect(_on_bait_selected)
	knives_list.item_selected.connect(_on_knife_selected)
	buy_button.pressed.connect(_on_buy_pressed)
	pay_debt_button.pressed.connect(_on_pay_debt_pressed)
	close_button.pressed.connect(_on_close_pressed)
	debt_amount.max_value = GameState.cash
	debt_amount.min_value = 1.0
	finn_line_label.text = Finn.get_shop_bark(GameState.debt)

func _populate_lists() -> void:
	rods_list.clear()
	baits_list.clear()
	knives_list.clear()
	for rod in ItemDatabase.get_all_rods():
		rods_list.add_item("%s  $%.2f" % [rod.name, rod.price])
		rods_list.set_item_metadata(rods_list.item_count - 1, rod.id)
	for bait in ItemDatabase.get_all_baits():
		baits_list.add_item("%s x%d  $%.2f" % [bait.name, bait.quantity, bait.price])
		baits_list.set_item_metadata(baits_list.item_count - 1, bait.id)
	for knife in ItemDatabase.get_all_knives():
		knives_list.add_item("%s  $%.2f" % [knife.name, knife.price])
		knives_list.set_item_metadata(knives_list.item_count - 1, knife.id)

func _on_rod_selected(index: int) -> void:
	_selected_type = "rod"
	_selected_id = String(rods_list.get_item_metadata(index))
	var rod := ItemDatabase.get_rod(_selected_id)
	if rod:
		info_label.text = "%s\nZone Access: %d\n%s" % [rod.name, rod.zone_access, rod.description]

func _on_bait_selected(index: int) -> void:
	_selected_type = "bait"
	_selected_id = String(baits_list.get_item_metadata(index))
	var bait := ItemDatabase.get_bait(_selected_id)
	if bait:
		info_label.text = "%s\nQty: %d\n%s" % [bait.name, bait.quantity, bait.description]

func _on_knife_selected(index: int) -> void:
	_selected_type = "knife"
	_selected_id = String(knives_list.get_item_metadata(index))
	var knife := ItemDatabase.get_knife(_selected_id)
	if knife:
		info_label.text = "%s\nMax Filet: %.1f\n%s" % [knife.name, knife.max_filet_mult, knife.description]

func _on_buy_pressed() -> void:
	if _selected_id.is_empty():
		return
	var price := 0.0
	match _selected_type:
		"rod":
			var rod := ItemDatabase.get_rod(_selected_id)
			if rod == null:
				return
			price = rod.price
			if GameState.cash < price:
				_not_enough_cash()
				return
			GameState.cash -= price
			GameState.unlock_rod(rod.id)
			if rod.tier == "pro":
				finn_line_label.text = "\n".join(Finn.get_reactive_lines("pro_rod"))
		"bait":
			var bait := ItemDatabase.get_bait(_selected_id)
			if bait == null:
				return
			price = bait.price
			if GameState.cash < price:
				_not_enough_cash()
				return
			GameState.cash -= price
			GameState.add_bait_stock(bait.id, bait.quantity)
			GameState.equip_bait(bait.id)
			TutorialManager.notify_action("bait_bought")
		"knife":
			var knife := ItemDatabase.get_knife(_selected_id)
			if knife == null:
				return
			price = knife.price
			if GameState.cash < price:
				_not_enough_cash()
				return
			GameState.cash -= price
			GameState.unlock_knife(knife.id)
	GameState.emit_cash_changed()
	debt_amount.max_value = GameState.cash
	finn_line_label.text = Finn.get_shop_bark(GameState.debt)
	info_label.text = "Purchased %s." % _selected_id

func _on_pay_debt_pressed() -> void:
	var amount := clamp(debt_amount.value, 1.0, min(GameState.cash, GameState.debt))
	if amount < 1.0:
		return
	var previous_debt := GameState.debt
	GameState.pay_debt(amount)
	if GameState.debt == 0.0:
		finn_line_label.text = "\n".join(Finn.get_reactive_lines("debt_cleared"))
	elif previous_debt - GameState.debt > 100.0:
		finn_line_label.text = "\n".join(Finn.get_reactive_lines("large_payment"))
	else:
		finn_line_label.text = "\n".join(Finn.get_reactive_lines("small_payment"))

func _on_close_pressed() -> void:
	TutorialManager.notify_action("shop_closed")
	SceneManager.close_overlay()
	if SceneManager.current_world_key == "town":
		AudioManager.play_music("town_night" if GameState.is_night() else "town_day")

func _not_enough_cash() -> void:
	finn_line_label.text = "\n".join(Finn.get_reactive_lines("cant_afford"))
	AudioManager.play_sfx("ui_error")
