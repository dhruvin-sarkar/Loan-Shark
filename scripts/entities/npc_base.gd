extends Area2D

# npc_base.gd - Base NPC behavior

signal npc_interacted()
signal dialogue_started(dialogue_path: String)

export var npc_type: String = "townsfolk"
export var dialogue_path: String = ""

var can_interact: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_show_interaction_prompt()

func _on_body_exited(body):
	if body.is_in_group("player"):
		_hide_interaction_prompt()

func interact():
	if can_interact:
		emit_signal("npc_interacted")
		if dialogue_path != "":
			emit_signal("dialogue_started", dialogue_path)

func _show_interaction_prompt():
	# Show interaction UI
	pass

func _hide_interaction_prompt():
	# Hide interaction UI
	pass

func set_dialogue(path: String):
	dialogue_path = path
