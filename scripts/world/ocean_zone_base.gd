extends Node2D

# ocean_zone_base.gd - Base class for all ocean zones

signal zone_entered()
signal zone_exited()

export var zone_name: String = "zone1"
export var zone_depth: int = 1
export var hazard_spawn_rate: float = 0.1

var fish_spawner: Node
var hazard_spawner: Node

func _ready():
	add_to_group("ocean_zone")
	_setup_parallax()
	_setup_spawn_points()
	_setup_transitions()
	
	emit_signal("zone_entered")

func _setup_parallax():
	# Setup parallax background layers
	pass

func _setup_spawn_points():
	# Setup fish and hazard spawn points
	pass

func _setup_transitions():
	# Setup zone transition areas
	pass

func _exit_tree():
	emit_signal("zone_exited")

func get_zone_name() -> String:
	return zone_name

func get_zone_depth() -> int:
	return zone_depth
