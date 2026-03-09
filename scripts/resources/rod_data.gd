extends Resource

# rod_data.gd - Rod data resource (GDD v3.0 compliant)

class_name RodData

@export var name: String = "Basic Rod"
@export var description: String = ""
@export var base_value: int = 50
@export var tier: String = "starter"  # starter, amateur, intermediate, pro
@export var max_zone: int = 1  # Maximum zone this rod can access
@export var cast_power: float = 1.0
@export var reel_speed: float = 1.0
@export var durability: int = 100
@export var luck_bonus: float = 0.0
@export var family_affinity: String = ""  # Optional family bonus
@export var affinity_bonus: float = 1.0  # Multiplier for family fish
@export var texture_path: String = ""
