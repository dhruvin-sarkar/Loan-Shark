extends CanvasLayer

@onready var fish_list: ItemList = $Panel/FishList
@onready var fish_details: Label = $Panel/FishDetails
@onready var completion_label: Label = $Panel/CompletionLabel
@onready var close_button: Button = $Panel/CloseButton

var _fish_entries: Array[FishData] = []

func _ready() -> void:
	close_button.pressed.connect(SceneManager.close_overlay)
	fish_list.item_selected.connect(_on_fish_selected)
	_populate_codex()

func _populate_codex() -> void:
	fish_list.clear()
	_fish_entries = FishDatabase.get_all_fish()
	_fish_entries.sort_custom(_sort_fish_entries)
	var discovered := 0
	for fish_data in _fish_entries:
		var is_discovered := bool(GameState.codex_discovered.get(fish_data.id, false))
		var index := fish_list.item_count
		fish_list.add_item(fish_data.name if is_discovered else "???")
		fish_list.set_item_metadata(index, fish_data.id)
		if is_discovered:
			discovered += 1
	completion_label.text = "%d / %d discovered" % [discovered, _fish_entries.size()]
	if discovered == _fish_entries.size():
		completion_label.text += "  COMPLETE"
	if not _fish_entries.is_empty():
		fish_list.select(0)
		_show_details(_fish_entries[0])

func _on_fish_selected(index: int) -> void:
	if index < 0 or index >= _fish_entries.size():
		return
	_show_details(_fish_entries[index])

func _show_details(fish_data: FishData) -> void:
	if not bool(GameState.codex_discovered.get(fish_data.id, false)):
		fish_details.text = "???\n\nDiscover this fish to unlock its codex entry."
		return
	fish_details.text = "%s\nZone %d  %s\nBase Price: $%.2f\nFamily: %s\n\n%s" % [
		fish_data.name,
		fish_data.zone,
		fish_data.rarity.capitalize(),
		fish_data.base_price,
		fish_data.family.capitalize(),
		fish_data.description
	]

func _sort_fish_entries(a: FishData, b: FishData) -> bool:
	if a.zone == b.zone:
		return a.name < b.name
	return a.zone < b.zone
