extends Resource
class_name FishData

@export var id: String = ""
@export var name: String = ""
@export var zone: int = 1
@export var base_price: float = 0.0
@export var size_range: Vector2 = Vector2(0.8, 1.8)
@export var rarity: String = "common"
@export var night_only: bool = false
@export var family: String = "pelagic"
@export var reel_speed: float = 1.0
@export var catch_speed: float = 1.0
@export var modifier_effect: String = ""
@export var description: String = ""
@export var inventory_slots: int = 1
@export var sprite_region: Rect2 = Rect2()
