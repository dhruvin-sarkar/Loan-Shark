extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var prompt_label: Label = $Panel/PromptLabel

func _ready() -> void:
	visible = false

func set_prompt(text: String, target_position: Vector2) -> void:
	prompt_label.text = text
	panel.position = target_position
	visible = true
