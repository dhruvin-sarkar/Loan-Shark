extends Node

# DialogueSystem.gd - Dialogue management system

signal dialogue_started(dialogue_id: String)
signal dialogue_line(speaker: String, text: String)
signal dialogue_choice(choices: Array)
signal dialogue_ended()

var current_dialogue: Array = []
var current_index: int = 0
var current_dialogue_id: String = ""
var is_active: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_dialogue(dialogue_path: String):
	if not ResourceLoader.exists(dialogue_path):
		push_error("Dialogue file not found: " + dialogue_path)
		return
	
	current_dialogue_id = dialogue_path
	current_dialogue = _parse_dialogue_file(dialogue_path)
	current_index = 0
	is_active = true
	
	emit_signal("dialogue_started", current_dialogue_id)
	_show_current_line()

func _parse_dialogue_file(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return []
	
	var lines = []
	var content = file.get_as_text()
	file.close()
	
	# Simple dialogue parser
	var sections = content.split("~")
	for section in sections:
		section = section.strip_edges()
		if section.is_empty():
			continue
		
		var section_lines = section.split("\n")
		for line in section_lines:
			line = line.strip_edges()
			if line.is_empty() or line.begins_with("=>"):
				continue
			
			var colon_pos = line.find(":")
			if colon_pos > 0:
				var speaker = line.substr(0, colon_pos).strip_edges()
				var text = line.substr(colon_pos + 1).strip_edges()
				lines.append({"speaker": speaker, "text": text})
	
	return lines

func _show_current_line():
	if current_index >= current_dialogue.size():
		end_dialogue()
		return
	
	var entry = current_dialogue[current_index]
	emit_signal("dialogue_line", entry.speaker, entry.text)

func advance():
	if not is_active:
		return
	
	current_index += 1
	_show_current_line()

func end_dialogue():
	is_active = false
	current_dialogue = []
	current_index = 0
	emit_signal("dialogue_ended")

func is_dialogue_active() -> bool:
	return is_active

func get_current_speaker() -> String:
	if current_index < current_dialogue.size():
		return current_dialogue[current_index].speaker
	return ""

func get_current_text() -> String:
	if current_index < current_dialogue.size():
		return current_dialogue[current_index].text
	return ""
