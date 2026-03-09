extends "res://scripts/entities/npc_base.gd"

# npc_roamer.gd - Roaming NPC behavior

export var roam_range: float = 100.0
export var roam_speed: float = 30.0

var home_position: Vector2
var target_position: Vector2
var is_roaming: bool = true

func _ready():
	npc_type = "roamer"
	super._ready()
	home_position = global_position
	_set_new_target()

func _process(delta):
	if is_roaming and not can_interact:
		_roam(delta)

func _roam(delta):
	var direction = (target_position - global_position).normalized()
	global_position += direction * roam_speed * delta
	
	if global_position.distance_to(target_position) < 5.0:
		_set_new_target()

func _set_new_target():
	var offset = Vector2(randf_range(-roam_range, roam_range), randf_range(-roam_range, roam_range))
	target_position = home_position + offset

func interact():
	is_roaming = false
	super.interact()
	await get_tree().create_timer(2.0).timeout
	is_roaming = true
