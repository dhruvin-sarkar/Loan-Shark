extends Resource

# bait_data.gd - Bait data resource (GDD v3.0 compliant)

class_name BaitData

@export var name: String = "Basic Bait"
@export var description: String = ""
@export var base_value: int = 5
@export var catch_bonus: float = 0.1
@export var rarity_bonus: float = 0.0
@export var uses: int = 10
@export var spawn_bonus: float = 1.0  # Multiplier on spawn rates
@export var target_family: String = ""  # Optional family targeting
@export var family_bonus: float = 1.0  # Bonus for target family
@export var deep_access: bool = false  # Allows zone 3-4 fishing
@export var texture_path: String = ""
