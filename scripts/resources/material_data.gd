extends Resource

# material_data.gd - Material data resource (GDD v3.0 compliant)

class_name MaterialData

@export var name: String = "Material"
@export var description: String = ""
@export var base_value: int = 5
@export var rarity: String = "common"  # common, uncommon, rare
@export var stack_size: int = 99
@export var zone_source: int = 1  # Which zone(s) this material can be found in
@export var texture_path: String = ""
