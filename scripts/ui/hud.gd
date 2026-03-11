extends CanvasLayer

@onready var day_label: Label = $DayLabel
@onready var timer_label: Label = $TimerLabel
@onready var cash_label: Label = $CashLabel
@onready var debt_label: Label = $DebtLabel
@onready var zone_label: Label = $ZoneLabel
@onready var greed_bar: ProgressBar = $GreedBar
@onready var notification_label: Label = $NotificationLabel
@onready var golden_sale_label: Label = $GoldenSaleLabel
@onready var charm_box: HBoxContainer = $CharmBox
@onready var inventory_bar: HBoxContainer = $InventoryBar

var _notification_tween: Tween = null
var _slot_buttons: Array[TextureButton] = []
var _slot_labels: Array[Label] = []

func _ready() -> void:
	for child in inventory_bar.get_children():
		if child is TextureButton:
			_slot_buttons.append(child)
			_slot_labels.append(_ensure_slot_label(child))
	GameState.cash_changed.connect(_update_cash)
	GameState.debt_changed.connect(_update_debt)
	GameState.day_changed.connect(_update_day)
	GameState.inventory_changed.connect(_refresh_inventory)
	_update_day(GameState.current_day)
	_update_cash(GameState.cash)
	_update_debt(GameState.debt)
	_refresh_inventory()
	_refresh_charms()
	call_deferred("_maybe_complete_debt_tutorial_step")

func _process(_delta: float) -> void:
	timer_label.text = _format_time(GameState.time_remaining)
	zone_label.visible = SceneManager.current_world_key == "ocean"
	zone_label.text = "Z%d" % GameState.current_zone
	greed_bar.visible = SceneManager.current_world_key == "ocean" and GameState.current_zone >= 3
	if greed_bar.visible:
		var ocean := get_tree().root.get_node_or_null("Main/WorldContainer/Ocean")
		if ocean and ocean.has_node("GreedMeter"):
			greed_bar.value = ocean.get_node("GreedMeter").greed_level * 100.0
	golden_sale_label.visible = ModifierStack.goldfish_bonus_active
	_refresh_charms()

func update_day_phase(_phase: String) -> void:
	pass

func show_notification(text: String) -> void:
	notification_label.text = text
	notification_label.visible = true
	if _notification_tween and _notification_tween.is_running():
		_notification_tween.kill()
	_notification_tween = create_tween()
	notification_label.position.x = -280.0
	_notification_tween.tween_property(notification_label, "position:x", 24.0, 0.25)
	_notification_tween.tween_interval(1.5)
	_notification_tween.tween_property(notification_label, "position:x", -280.0, 0.25)
	await _notification_tween.finished
	notification_label.visible = false

func _update_day(day: int) -> void:
	day_label.text = "Day %d / 7" % min(day, 7)

func _update_cash(amount: float) -> void:
	cash_label.text = "$%.2f" % amount

func _update_debt(amount: float) -> void:
	debt_label.text = "$%.2f" % amount
	var pulse := create_tween()
	debt_label.modulate = Color(1.0, 0.4, 0.4)
	pulse.tween_property(debt_label, "modulate", Color.WHITE, 0.4)

func _refresh_inventory() -> void:
	var used := 0
	for index in range(_slot_buttons.size()):
		var button := _slot_buttons[index]
		var label := _slot_labels[index]
		label.text = ""
		button.tooltip_text = ""
		button.modulate = Color(1.0, 1.0, 1.0, 0.35)
	for fish in GameState.fish_inventory:
		var slots := int(fish.get("inventory_slots", 1))
		var stars := int(round(float(fish.get("reel_quality", 0.0)) * 5.0))
		var slot_text := "%s\n%s" % [fish.get("name", "Fish"), "*" * stars]
		for index in range(slots):
			if used + index < _slot_buttons.size():
				_slot_labels[used + index].text = slot_text if index == 0 else "..."
				_slot_buttons[used + index].tooltip_text = fish.get("name", "Fish")
				_slot_buttons[used + index].modulate = Color.WHITE
		used += slots

func _refresh_charms() -> void:
	for child in charm_box.get_children():
		if child is Label:
			child.queue_free()
	for charm_id_variant in GameState.active_charms:
		var label := Label.new()
		label.text = String(charm_id_variant)
		if ModifierStack.sea_angel_active:
			label.modulate = Color(0.7, 1.0, 1.0)
		charm_box.add_child(label)

func _format_time(seconds: float) -> String:
	var total := int(max(seconds, 0.0))
	var minutes := total / 60
	var remainder := total % 60
	return "%02d:%02d" % [minutes, remainder]

func _ensure_slot_label(button: TextureButton) -> Label:
	var label := button.get_node_or_null("SlotLabel") as Label
	if label != null:
		return label
	label = Label.new()
	label.name = "SlotLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.offset_left = 4.0
	label.offset_top = 4.0
	label.offset_right = 60.0
	label.offset_bottom = 60.0
	button.add_child(label)
	return label

func _maybe_complete_debt_tutorial_step() -> void:
	if GameState.tutorial_completed:
		return
	if TutorialManager.current_step != TutorialManager.TutorialStep.SHOW_DEBT_METER:
		return
	await get_tree().create_timer(0.4).timeout
	if TutorialManager.current_step == TutorialManager.TutorialStep.SHOW_DEBT_METER:
		TutorialManager.notify_action("debt_seen")
