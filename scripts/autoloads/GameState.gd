extends Node
class_name GameState

signal debt_changed(new_debt: float)
signal cash_changed(new_cash: float)
signal day_changed(new_day: int)
signal fish_caught(fish_instance: Dictionary)
signal inventory_changed()

var debt: float = 500.0
var cash: float = 20.0
var current_day: int = 1
var day_duration: float = 600.0
var time_remaining: float = 600.0
var is_day_active: bool = false
var fish_inventory: Array = []
var materials_inventory: Dictionary = {}
var equipped_rod: String = "rod_driftwood"
var equipped_bait: String = ""
var bait_quantity: int = 0
var equipped_knife: String = "knife_rusty"
var active_charms: Array = []
var rod_enchantment: String = ""
var daily_modifier_log: Array = []
var tutorial_completed: bool = false
var codex_discovered: Dictionary = {}
var days_without_payment: int = 0
var coelacanth_caught_today: bool = false

var current_zone: int = 1
var total_fish_caught: int = 0
var total_earned: float = 0.0
var debt_paid_today: float = 0.0
var today_interest_added: float = 0.0
var fish_caught_today: Array = []
var last_sale_breakdown: Array = []
var last_day_summary: Dictionary = {}
var owned_rods: Array[String] = ["rod_driftwood"]
var owned_knives: Array[String] = ["knife_rusty"]
var bait_inventory: Dictionary = {}

func _ready() -> void:
	reset_run()

func reset_run() -> void:
	debt = 500.0
	cash = 20.0
	current_day = 1
	day_duration = 600.0
	time_remaining = 600.0
	is_day_active = false
	fish_inventory.clear()
	materials_inventory.clear()
	equipped_rod = "rod_driftwood"
	equipped_bait = ""
	bait_quantity = 0
	equipped_knife = "knife_rusty"
	active_charms.clear()
	rod_enchantment = ""
	daily_modifier_log.clear()
	tutorial_completed = false
	codex_discovered.clear()
	days_without_payment = 0
	coelacanth_caught_today = false
	current_zone = 1
	total_fish_caught = 0
	total_earned = 0.0
	debt_paid_today = 0.0
	today_interest_added = 0.0
	fish_caught_today.clear()
	last_sale_breakdown.clear()
	last_day_summary.clear()
	owned_rods = ["rod_driftwood"]
	owned_knives = ["knife_rusty"]
	bait_inventory.clear()
	_emit_all_state()

func _emit_all_state() -> void:
	debt_changed.emit(debt)
	cash_changed.emit(cash)
	day_changed.emit(current_day)
	inventory_changed.emit()

func pay_debt(amount: float) -> void:
	var payment := clamp(amount, 0.0, min(cash, debt))
	if payment <= 0.0:
		return
	cash -= payment
	debt -= payment
	debt_paid_today += payment
	if debt <= 0.0:
		debt = 0.0
	cash_changed.emit(cash)
	debt_changed.emit(debt)
	if debt == 0.0:
		SceneManager.show_win_screen()

func end_of_day() -> void:
	is_day_active = false
	today_interest_added = 0.0
	if debt > 0.0:
		var previous_debt := debt
		debt = round(debt * 1.05 * 100.0) / 100.0
		today_interest_added = round((debt - previous_debt) * 100.0) / 100.0
		if debt_paid_today > 0.0:
			days_without_payment = 0
		else:
			days_without_payment += 1
		debt_changed.emit(debt)
	else:
		days_without_payment = 0
	if debt > 1000.0:
		SceneManager.show_game_over("debt_spiral")
		return
	var today_total := 0.0
	for entry in last_sale_breakdown:
		today_total += float(entry.get("total_price", 0.0))
	last_day_summary = {
		"day": current_day,
		"fish_caught": fish_caught_today.duplicate(true),
		"sale_breakdown": last_sale_breakdown.duplicate(true),
		"total_earned_today": round(today_total * 100.0) / 100.0,
		"debt_paid_today": round(debt_paid_today * 100.0) / 100.0,
		"interest_added": today_interest_added,
		"new_debt_total": debt,
		"days_remaining": max(0, 7 - current_day)
	}
	current_day += 1
	day_changed.emit(current_day)
	if current_day > 7 and debt > 0.0:
		SceneManager.show_game_over("time_out")
		return
	time_remaining = day_duration
	active_charms.clear()
	coelacanth_caught_today = false
	ModifierStack.reset_for_new_day()
	SceneManager.show_day_end_summary()
	SaveSystem.save_state(self)

func begin_next_day() -> void:
	debt_paid_today = 0.0
	today_interest_added = 0.0
	fish_caught_today.clear()
	last_sale_breakdown.clear()
	is_day_active = true

func add_fish(fish_data: Dictionary) -> bool:
	var fish_instance := fish_data.duplicate(true)
	var slots_required := int(fish_instance.get("inventory_slots", 1))
	var available_slots := get_available_fish_slots()
	if available_slots <= 0:
		return false
	if fish_instance.get("id", "") == "lanternfish":
		slots_required = min(slots_required, available_slots)
		if slots_required <= 0:
			return false
		fish_instance["inventory_slots"] = slots_required
		fish_instance["stack_count"] = slots_required
	elif slots_required > available_slots:
		return false
	fish_inventory.append(fish_instance)
	codex_discovered[fish_instance.get("id", "")] = true
	fish_caught_today.append(fish_instance.duplicate(true))
	total_fish_caught += int(fish_instance.get("stack_count", 1))
	fish_caught.emit(fish_instance.duplicate(true))
	inventory_changed.emit()
	return true

func get_available_fish_slots() -> int:
	return max(0, 12 - get_used_fish_slots())

func get_used_fish_slots() -> int:
	var used := 0
	for fish in fish_inventory:
		used += int(fish.get("inventory_slots", 1))
	return used

func sell_all_fish() -> float:
	var total := 0.0
	last_sale_breakdown.clear()
	for fish in fish_inventory:
		var quantity := int(fish.get("stack_count", 1))
		for index in range(quantity):
			var single_fish := fish.duplicate(true)
			single_fish["stack_count"] = 1
			var price := float(single_fish.get("base_price", 0.0))
			price *= float(single_fish.get("size_mult", 1.0))
			price *= float(single_fish.get("reel_quality", 0.0))
			price *= float(single_fish.get("filet_mult", 1.0))
			if single_fish.get("id", "") == "ghost_crab" and single_fish.get("caught_at_night", false):
				price *= 1.5
			price = ModifierStack.apply_sell_multipliers(price, single_fish)
			total += price
			last_sale_breakdown.append({
				"id": single_fish.get("id", ""),
				"name": single_fish.get("name", ""),
				"total_price": price,
				"sale_index": index
			})
	fish_inventory.clear()
	total = round(total * 100.0) / 100.0
	cash += total
	total_earned += total
	cash_changed.emit(cash)
	inventory_changed.emit()
	SaveSystem.save_state(self)
	return total

func is_night() -> bool:
	return time_remaining <= 150.0

func add_material(material_id: String, quantity: int = 1) -> void:
	materials_inventory[material_id] = int(materials_inventory.get(material_id, 0)) + quantity
	inventory_changed.emit()

func remove_material(material_id: String, quantity: int = 1) -> bool:
	var current := int(materials_inventory.get(material_id, 0))
	if current < quantity:
		return false
	current -= quantity
	if current <= 0:
		materials_inventory.erase(material_id)
	else:
		materials_inventory[material_id] = current
	inventory_changed.emit()
	return true

func add_bait_stock(bait_id: String, quantity: int) -> void:
	bait_inventory[bait_id] = int(bait_inventory.get(bait_id, 0)) + quantity
	if equipped_bait.is_empty():
		equip_bait(bait_id)

func equip_bait(bait_id: String) -> void:
	equipped_bait = bait_id
	bait_quantity = int(bait_inventory.get(bait_id, 0))
	inventory_changed.emit()

func consume_bait() -> void:
	if equipped_bait.is_empty():
		return
	bait_quantity = max(0, bait_quantity - 1)
	if bait_quantity == 0:
		bait_inventory.erase(equipped_bait)
		equipped_bait = ""
	else:
		bait_inventory[equipped_bait] = bait_quantity
	inventory_changed.emit()

func unlock_rod(rod_id: String) -> void:
	if not owned_rods.has(rod_id):
		owned_rods.append(rod_id)
	equipped_rod = rod_id
	inventory_changed.emit()

func unlock_knife(knife_id: String) -> void:
	if not owned_knives.has(knife_id):
		owned_knives.append(knife_id)
	equipped_knife = knife_id
	inventory_changed.emit()

func save() -> void:
	SaveSystem.save_state(self)

func load_save() -> void:
	SaveSystem.load_state(self)

func to_save_dictionary() -> Dictionary:
	return {
		"version": 1,
		"day": current_day,
		"time_remaining": time_remaining,
		"debt": debt,
		"cash": cash,
		"fish_inventory": fish_inventory,
		"materials": materials_inventory,
		"rod": equipped_rod,
		"rod_enchantment": rod_enchantment,
		"bait": equipped_bait,
		"bait_qty": bait_quantity,
		"knife": equipped_knife,
		"charms": active_charms,
		"codex": codex_discovered,
		"tutorial_done": tutorial_completed,
		"days_no_payment": days_without_payment,
		"coelacanth_caught_today": coelacanth_caught_today,
		"owned_rods": owned_rods,
		"owned_knives": owned_knives,
		"bait_inventory": bait_inventory,
		"current_zone": current_zone,
		"total_fish_caught": total_fish_caught,
		"total_earned": total_earned
	}

func apply_loaded_state(data: Dictionary) -> void:
	debt = float(data.get("debt", 500.0))
	cash = float(data.get("cash", 20.0))
	current_day = int(data.get("day", 1))
	time_remaining = float(data.get("time_remaining", day_duration))
	is_day_active = false
	fish_inventory = data.get("fish_inventory", []).duplicate(true)
	materials_inventory = data.get("materials", {}).duplicate(true)
	equipped_rod = String(data.get("rod", "rod_driftwood"))
	rod_enchantment = String(data.get("rod_enchantment", ""))
	equipped_bait = String(data.get("bait", ""))
	bait_quantity = int(data.get("bait_qty", 0))
	equipped_knife = String(data.get("knife", "knife_rusty"))
	active_charms = data.get("charms", []).duplicate(true)
	codex_discovered = data.get("codex", {}).duplicate(true)
	tutorial_completed = bool(data.get("tutorial_done", false))
	days_without_payment = int(data.get("days_no_payment", 0))
	coelacanth_caught_today = bool(data.get("coelacanth_caught_today", false))
	owned_rods = data.get("owned_rods", ["rod_driftwood"]).duplicate(true)
	owned_knives = data.get("owned_knives", ["knife_rusty"]).duplicate(true)
	bait_inventory = data.get("bait_inventory", {}).duplicate(true)
	current_zone = int(data.get("current_zone", 1))
	total_fish_caught = int(data.get("total_fish_caught", 0))
	total_earned = float(data.get("total_earned", 0.0))
	debt_paid_today = 0.0
	today_interest_added = 0.0
	fish_caught_today.clear()
	last_sale_breakdown.clear()
	last_day_summary.clear()
	_emit_all_state()
