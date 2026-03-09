extends Resource

# crafting_recipe.gd - Crafting recipe resource (GDD v3.0 compliant)

class_name CraftingRecipe

@export var recipe_name: String = "Recipe"
@export var result_charm_id: String = ""  # ID of charm this creates
@export var result_type: String = "sell"  # sell, spawn, enchantment
@export var materials_required: Dictionary = {}  # material_id -> exact quantity
@export var effect_description: String = ""
@export var texture_path: String = ""
