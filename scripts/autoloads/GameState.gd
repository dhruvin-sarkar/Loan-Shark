extends Node

# GameState.gd - Global game state manager (GDD v3.0 compliant)
# Single source of truth for ALL persistent game data.

signal cash_changed(amount: float)
signal debt_changed(amount: float)
signal day_changed(day: int)
signal game_over(reason: String)
signal game_won()
signal time_updated(time_remaining: float)

# === FINANCIAL ===
var debt: float = 500.0          # Starting debt. Ticks +5% per unpaid day.
var cash: float = 20.0           # Starting cash in hand.

# === TIME ===
var current_day: int = 1         # 1 through 7.
var day_duration: float = 600.0  # 10 minutes per day in seconds.
var time_remaining: float = 600.0 # Ticking down each frame.
var is_day_active: bool = false  # False during transitions and day-end screen.

# === INVENTORY ===
# Fish inventory: Array of dictionaries, max 12 entries.
# Each dict: { id, name, base_price, size_mult, reel_quality, fileted, filet_mult }
var fish_inventory: Array = []

# Materials inventory: Key = material_id, Value = quantity.
var materials_inventory: Dictionary = {}

# === EQUIPMENT ===
var equipped_rod: String = "rod_driftwood"    # Resource ID string.
var equipped_bait: String = ""                # Empty = no bait.
var bait_quantity: int = 0
var equipped_knife: String = "knife_rusty"    # Starts with rusty knife.
var active_charms: Array = []                 # Max 2 charm resource IDs.

# === ROGUELITE ===
var rod_enchantment: String = ""     # Current enchantment on the rod. Empty = none.
var daily_modifier_log: Array = []   # Log of modifiers active today.

# === FLAGS ===
var tutorial_completed: bool = false
var codex_discovered: Dictionary = {}  # fish_id: true/false for discovered fish.
var days_without_payment: int = 0     # Tracks consecutive unpaid days.
var coelacanth_caught_today: bool = false  # Legendary cap tracking (GDD Section 27)

const MAX_DAYS: int = 7
const MAX_FISH_SLOTS: int = 12
const STARTING_DEBT: float = 500.0
const STARTING_CASH: float = 20.0
const INTEREST_RATE: float = 0.05  # 5% compound interest

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if is_day_active:
		time_remaining -= delta
		emit_signal("time_updated", time_remaining)
		if time_remaining <= 0:
			end_of_day()

func start_new_game():
	debt = STARTING_DEBT
	cash = STARTING_CASH
	current_day = 1
	time_remaining = day_duration
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

func reset_game():
	start_new_game()

# === FINANCIAL METHODS ===

func add_cash(amount: float):
	cash += amount
	emit_signal("cash_changed", cash)

func remove_cash(amount: float) -> bool:
	if cash >= amount:
		cash -= amount
		emit_signal("cash_changed", cash)
		return true
	return false

func pay_debt(amount: float) -> void:
	# Subtracts from debt. If debt hits 0, trigger win.
	if cash >= amount and debt > 0:
		cash -= amount
		debt -= amount
		if debt <= 0:
			debt = 0
			emit_signal("game_won")
		emit_signal("cash_changed", cash)
		emit_signal("debt_changed", debt)
		days_without_payment = 0

func end_of_day() -> void:
	is_day_active = false
	
	# Apply interest if debt unpaid.
	if debt > 0:
		debt *= (1.0 + INTEREST_RATE)  # 5% compound interest.
		debt = round(debt * 100.0) / 100.0  # Round to 2 decimal places.
		days_without_payment += 1
		emit_signal("debt_changed", debt)
	else:
		days_without_payment = 0
	
	# Check lose condition - debt spiral.
	if debt > 1000.0:
		emit_signal("game_over", "debt_spiral")
		return
	
	# Advance day.
	current_day += 1
	emit_signal("day_changed", current_day)
	
	# Check lose condition - time out.
	if current_day > MAX_DAYS and debt > 0:
		emit_signal("game_over", "time_out")
		return
	
	# Reset daily variables.
	time_remaining = day_duration
	active_charms.clear()
	daily_modifier_log.clear()
	coelacanth_caught_today = false
	
	# Show day end summary via SceneManager
	SceneManager.show_day_end_summary()

func start_day():
	is_day_active = true
	time_remaining = day_duration

# === FISH INVENTORY METHODS ===

func add_fish(fish_data: Dictionary) -> bool:
	# Returns false if inventory full.
	if fish_inventory.size() >= MAX_FISH_SLOTS:
		return false
	fish_inventory.append(fish_data)
	codex_discovered[fish_data.id] = true
	return true

func remove_fish(index: int) -> Dictionary:
	if index >= 0 and index < fish_inventory.size():
		var fish = fish_inventory[index]
		fish_inventory.remove_at(index)
		return fish
	return {}

func get_fish_count() -> int:
	return fish_inventory.size()

func is_inventory_full() -> bool:
	return fish_inventory.size() >= MAX_FISH_SLOTS

func sell_all_fish() -> float:
	# Calculates total sale value of all fish. Clears inventory. Returns total.
	var total = 0.0
	for fish in fish_inventory:
		var price = fish.base_price
		price *= fish.get("size_mult", 1.0)
		price *= fish.get("reel_quality", 1.0)
		if fish.get("fileted", false):
			price *= fish.get("filet_mult", 1.0)
		# Apply modifier stack multipliers
		price = ModifierStack.apply_sell_multipliers(price, fish)
		total += price
	fish_inventory.clear()
	cash += total
	emit_signal("cash_changed", cash)
	return total

# === MATERIAL INVENTORY METHODS ===

func add_material(material_id: String, quantity: int = 1):
	if materials_inventory.has(material_id):
		materials_inventory[material_id] += quantity
	else:
		materials_inventory[material_id] = quantity

func remove_material(material_id: String, quantity: int = 1) -> bool:
	if materials_inventory.has(material_id) and materials_inventory[material_id] >= quantity:
		materials_inventory[material_id] -= quantity
		if materials_inventory[material_id] <= 0:
			materials_inventory.erase(material_id)
		return true
	return false

func get_material_count(material_id: String) -> int:
	return materials_inventory.get(material_id, 0)

# === EQUIPMENT METHODS ===

func equip_rod(rod_id: String):
	equipped_rod = rod_id

func equip_bait(bait_id: String, quantity: int):
	equipped_bait = bait_id
	bait_quantity = quantity

func use_bait() -> bool:
	if bait_quantity > 0:
		bait_quantity -= 1
		if bait_quantity <= 0:
			equipped_bait = ""
		return true
	return false

func equip_knife(knife_id: String):
	equipped_knife = knife_id

func add_charm(charm_id: String) -> bool:
	if active_charms.size() < 2:
		active_charms.append(charm_id)
		return true
	return false

func remove_charm(charm_id: String):
	active_charms.erase(charm_id)

func set_enchantment(enchantment_id: String):
	rod_enchantment = enchantment_id

# === SAVE/LOAD ===

func save() -> Dictionary:
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
		"coelacanth_caught_today": coelacanth_caught_today
	}

func load_save(data: Dictionary):
	current_day = data.get("day", 1)
	time_remaining = data.get("time_remaining", day_duration)
	debt = data.get("debt", STARTING_DEBT)
	cash = data.get("cash", STARTING_CASH)
	fish_inventory = data.get("fish_inventory", [])
	materials_inventory = data.get("materials", {})
	equipped_rod = data.get("rod", "rod_driftwood")
	rod_enchantment = data.get("rod_enchantment", "")
	equipped_bait = data.get("bait", "")
	bait_quantity = data.get("bait_qty", 0)
	equipped_knife = data.get("knife", "knife_rusty")
	active_charms = data.get("charms", [])
	codex_discovered = data.get("codex", {})
	tutorial_completed = data.get("tutorial_done", false)
	days_without_payment = data.get("days_no_payment", 0)
	coelacanth_caught_today = data.get("coelacanth_caught_today", false)
