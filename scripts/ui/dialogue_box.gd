extends Control

# dialogue_box.gd - Dialogue display controller

signal dialogue_finished()
signal choice_selected(choice_index: int)

@onready var speaker_name: Label = $Panel/VBoxContainer/SpeakerName
@onready var dialogue_text: RichTextLabel = $Panel/VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $Panel/VBoxContainer/ChoicesContainer
@onready var continue_prompt: Label = $Panel/VBoxContainer/ContinuePrompt

var current_dialogue: Array = []
var current_index: int = 0
var is_active: bool = false

func _ready():
	hide()
	continue_prompt.hide()

func _input(event):
	if event.is_action_pressed("ui_accept") and is_active:
		_advance_dialogue()

func start_dialogue(dialogue_data: Array):
	current_dialogue = dialogue_data
	current_index = 0
	is_active = true
	show()
	_display_current()

func _display_current():
	if current_index >= current_dialogue.size():
		end_dialogue()
		return
	
	var entry = current_dialogue[current_index]
	speaker_name.text = entry.get("speaker", "???")
	dialogue_text.text = entry.get("text", "")
	
	if entry.has("choices"):
		_show_choices(entry.choices)
	else:
		choices_container.hide()
		continue_prompt.show()

func _show_choices(choices: Array):
	choices_container.show()
	continue_prompt.hide()
	
	for child in choices_container.get_children():
		child.queue_free()
	
	for i in range(choices.size()):
		var button = Button.new()
		button.text = choices[i]
		button.pressed.connect(_on_choice_pressed.bind(i))
		choices_container.add_child(button)

func _advance_dialogue():
	current_index += 1
	_display_current()

func _on_choice_pressed(index: int):
	emit_signal("choice_selected", index)
	end_dialogue()

func end_dialogue():
	is_active = false
	current_dialogue = []
	hide()
	emit_signal("dialogue_finished")
