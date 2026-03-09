extends Resource

# fish_data.gd - Fish data resource (GDD v3.0 compliant)

class_name FishData

@export var name: String = "Unknown Fish"
@export var id: String = ""
@export var zone: String = "zone1"

# Pricing
@export var base_price: int = 10  # Base sell price in dollars
@export var size_range: Array = [0.8, 1.8]  # [min_size_mult, max_size_mult]

# Classification
@export var rarity: String = "common"  # common, uncommon, rare, ultra-rare, legendary
@export var family: String = "pelagic"  # pelagic, crustacean, reef, bony, deep, eel, cephalopod
@export var night_only: bool = false

# Minigame difficulty
@export var reel_speed: float = 1.0  # Multiplier on reel bar oscillation speed
@export var catch_speed: float = 1.0  # Multiplier on catch minigame red zone speed

# Special effects
@export var modifier_effect: String = ""  # Special modifier on catch
@export var inventory_slots: int = 1  # Oarfish takes 2 slots

# Display
@export var description: String = ""
@export var texture_path: String = ""

func get_avg_size() -> float:
	return (size_range[0] + size_range[1]) / 2.0
