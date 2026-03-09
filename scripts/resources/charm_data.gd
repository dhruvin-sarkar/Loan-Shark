extends Resource

# charm_data.gd - Charm data resource (GDD v3.0 compliant)

class_name CharmData

@export var name: String = "Charm"
@export var description: String = ""
@export var base_value: int = 100
@export var charm_type: String = "sell"  # sell, spawn, enchantment
@export var effect_value: float = 1.0  # Multiplier or bonus value
@export var target_family: String = ""  # Optional family targeting
@export var duration: int = 1  # How many days the charm lasts (0 = permanent)
@export var texture_path: String = ""
