extends CanvasLayer

signal dialogue_finished

@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var text_label: Label = $Panel/TextLabel
@onready var continue_label: Label = $Panel/ContinueLabel

var _lines: Array[String] = []
var _current_index: int = 0
var _visible_characters: int = 0
var _typing_speed: float = 48.0
var _char_timer: float = 0.0
var _typing: bool = false
var _blip_key: String = "townsfolk_blip"

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if not visible or _lines.is_empty():
		return
	if _typing:
		_char_timer += delta * _typing_speed
		var target_line := _lines[_current_index]
		while _char_timer >= 1.0 and _visible_characters < target_line.length():
			_char_timer -= 1.0
			_visible_characters += 1
			if _visible_characters % 2 == 0:
				AudioManager.play_sfx(_blip_key)
			text_label.text = target_line.substr(0, _visible_characters)
		if _visible_characters >= target_line.length():
			_typing = false
			continue_label.visible = true
	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func open_dialogue(speaker_name: String, lines: Array[String], blip_key: String) -> void:
	_lines = lines.duplicate()
	_current_index = 0
	_visible_characters = 0
	_char_timer = 0.0
	_typing = true
	_blip_key = blip_key
	speaker_label.text = speaker_name
	text_label.text = ""
	continue_label.visible = false
	visible = true

func _advance() -> void:
	if _lines.is_empty():
		return
	var current_line := _lines[_current_index]
	if _typing:
		_typing = false
		_visible_characters = current_line.length()
		text_label.text = current_line
		continue_label.visible = true
		return
	_current_index += 1
	if _current_index >= _lines.size():
		visible = false
		_lines.clear()
		dialogue_finished.emit()
		if TutorialManager.current_step == TutorialManager.TutorialStep.INTRO_DIALOGUE:
			TutorialManager.notify_action("intro_dismissed")
		return
	_visible_characters = 0
	_char_timer = 0.0
	_typing = true
	continue_label.visible = false
	text_label.text = ""
