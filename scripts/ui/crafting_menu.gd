extends Control

# crafting_menu.gd - Crafting UI controller

signal crafting_closed()

@onready var recipe_list: ItemList = $Panel/VBoxContainer/RecipeList
@onready var craft_button: Button = $Panel/VBoxContainer/CraftButton
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

var selected_recipe: Resource = null

func _ready():
	craft_button.pressed.connect(_on_craft_pressed)
	close_button.pressed.connect(_on_close_pressed)
	_populate_recipes()

func _populate_recipes():
	recipe_list.clear()
	
	# Load crafting recipes
	var recipes_path = "res://resources/crafting_recipes/"
	for file in DirAccess.get_files_at(recipes_path):
		if file.ends_with(".tres"):
			var recipe = load(recipes_path + file)
			recipe_list.add_item(recipe.name)

func _on_recipe_selected(index: int):
	selected_recipe = recipe_list.get_item_metadata(index)
	craft_button.disabled = not _can_craft(selected_recipe)

func _can_craft(recipe: Resource) -> bool:
	for requirement in recipe.requirements:
		if not GameState.has_material(requirement.id, requirement.count):
			return false
	return true

func _on_craft_pressed():
	if selected_recipe and _can_craft(selected_recipe):
		_consume_materials(selected_recipe)
		GameState.add_item(selected_recipe.result_id)

func _consume_materials(recipe: Resource):
	for requirement in recipe.requirements:
		GameState.remove_material(requirement.id, requirement.count)

func _on_close_pressed():
	emit_signal("crafting_closed")
	hide()
