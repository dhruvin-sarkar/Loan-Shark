extends CanvasLayer

const RECIPE_PATHS: Array[String] = [
	"res://resources/crafting_recipes/recipe_shell_charm.tres",
	"res://resources/crafting_recipes/recipe_coral_charm.tres",
	"res://resources/crafting_recipes/recipe_deep_charm.tres",
	"res://resources/crafting_recipes/recipe_tide_charm.tres",
	"res://resources/crafting_recipes/recipe_gold_charm.tres",
	"res://resources/crafting_recipes/recipe_night_charm.tres",
	"res://resources/crafting_recipes/recipe_blood_charm.tres",
	"res://resources/crafting_recipes/recipe_ink_charm.tres",
	"res://resources/crafting_recipes/recipe_eel_ward.tres",
	"res://resources/crafting_recipes/recipe_siren_charm.tres",
	"res://resources/crafting_recipes/recipe_crustacean_call.tres",
	"res://resources/crafting_recipes/recipe_bony_lure.tres",
	"res://resources/crafting_recipes/recipe_depth_pulse.tres",
	"res://resources/crafting_recipes/recipe_fortune_bait.tres",
	"res://resources/crafting_recipes/recipe_calm_tide.tres",
	"res://resources/crafting_recipes/recipe_frenzy_charm.tres",
	"res://resources/crafting_recipes/recipe_tide_blessing.tres",
	"res://resources/crafting_recipes/recipe_deep_lure.tres",
	"res://resources/crafting_recipes/recipe_fortune_hook.tres",
	"res://resources/crafting_recipes/recipe_ghost_bait.tres",
	"res://resources/crafting_recipes/recipe_calm_waters.tres",
	"res://resources/crafting_recipes/recipe_blood_tide.tres",
	"res://resources/crafting_recipes/recipe_echo_line.tres",
	"res://resources/crafting_recipes/recipe_weighted_sink.tres"
]

@onready var recipe_list: ItemList = $Panel/RecipeList
@onready var detail_label: Label = $Panel/DetailLabel
@onready var craft_button: Button = $Panel/CraftButton
@onready var close_button: Button = $Panel/CloseButton

var _recipes: Array[CraftingRecipeData] = []
var _selected_recipe: CraftingRecipeData = null

func _ready() -> void:
	_load_recipes()
	recipe_list.item_selected.connect(_on_recipe_selected)
	craft_button.pressed.connect(_on_craft_pressed)
	close_button.pressed.connect(SceneManager.close_overlay)

func _load_recipes() -> void:
	_recipes.clear()
	recipe_list.clear()
	for path in RECIPE_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var recipe := load(path) as CraftingRecipeData
		if recipe == null:
			continue
		var index := recipe_list.item_count
		recipe_list.add_item(recipe.name)
		recipe_list.set_item_metadata(index, recipe.id)
		_recipes.append(recipe)
	if not _recipes.is_empty():
		recipe_list.select(0)
		_select_recipe(_recipes[0])

func _on_recipe_selected(index: int) -> void:
	if index < 0 or index >= _recipes.size():
		return
	_select_recipe(_recipes[index])

func _select_recipe(recipe: CraftingRecipeData) -> void:
	_selected_recipe = recipe
	var lines: Array[String] = [recipe.name, recipe.description, "", "Ingredients:"]
	for material_id in recipe.ingredients.keys():
		var needed := int(recipe.ingredients.get(material_id, 0))
		var owned := int(GameState.materials_inventory.get(material_id, 0))
		lines.append("%s %d / %d" % [_prettify_id(String(material_id)), owned, needed])
	detail_label.text = "\n".join(lines)
	craft_button.disabled = not _can_craft(recipe)

func _can_craft(recipe: CraftingRecipeData) -> bool:
	for material_id in recipe.ingredients.keys():
		if int(GameState.materials_inventory.get(material_id, 0)) < int(recipe.ingredients.get(material_id, 0)):
			return false
	return true

func _on_craft_pressed() -> void:
	if _selected_recipe == null or not _can_craft(_selected_recipe):
		SceneManager.show_notification("Missing Materials")
		return
	var charm := ItemDatabase.get_charm(_selected_recipe.result_id)
	if charm == null:
		SceneManager.show_notification("Invalid Recipe")
		return
	if charm.is_enchantment:
		pass
	else:
		if GameState.active_charms.size() >= 2 and not GameState.active_charms.has(charm.id):
			SceneManager.show_notification("Charm Slots Full")
			return
		if GameState.active_charms.has(charm.id):
			SceneManager.show_notification("Charm Already Active")
			return
	for material_id in _selected_recipe.ingredients.keys():
		GameState.remove_material(String(material_id), int(_selected_recipe.ingredients.get(material_id, 0)))
	if charm.is_enchantment:
		GameState.rod_enchantment = charm.enchantment_id
		SceneManager.show_notification("Enchanted Rod: %s" % charm.name)
	else:
		GameState.active_charms.append(charm.id)
		SceneManager.show_notification("Crafted %s" % charm.name)
	GameState.emit_inventory_changed()
	_select_recipe(_selected_recipe)

func _prettify_id(value: String) -> String:
	return value.replace("_", " ").capitalize()
