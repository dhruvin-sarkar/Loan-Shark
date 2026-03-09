extends "res://scripts/entities/npc_base.gd"

# npc_shopkeeper.gd - Shopkeeper NPC

signal shop_opened()

var shop_inventory: Dictionary = {}

func _ready():
	npc_type = "shopkeeper"
	super._ready()
	_setup_shop_inventory()

func _setup_shop_inventory():
	shop_inventory = {
		"rods": ["rod_driftwood", "rod_amateur_shell"],
		"baits": ["bait_earthworm", "bait_maggot"],
		"charms": ["charm_shell", "charm_coral"]
	}

func interact():
	if can_interact:
		emit_signal("shop_opened")
		# Open shop UI
		GameState.open_shop()

func get_dialogue_for_day() -> String:
	var day = GameState.day
	return "res://resources/dialogue/shopkeeper_day%d.dialogue" % day
