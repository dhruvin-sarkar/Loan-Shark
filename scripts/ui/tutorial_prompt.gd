extends Control

# tutorial_prompt.gd - Tutorial text prompt

signal prompt_dismissed()

@onready var prompt_label: Label = $Panel/PromptLabel

func _ready():
	hide()

func show_prompt(text: String):
	prompt_label.text = text
	show()

func _input(event):
	if event.is_action_pressed("ui_accept") and visible:
		emit_signal("prompt_dismissed")
		hide()
