extends CanvasLayer

@onready var name_label: Label = $Panel/NameLabel
@onready var value_label: Label = $Panel/ValueLabel
@onready var stars_label: Label = $Panel/StarsLabel
@onready var panel: Panel = $Panel

func show_fish(fish: Dictionary) -> void:
	name_label.text = String(fish.get("name", "Fish"))
	var estimated := float(fish.get("base_price", 0.0)) * float(fish.get("size_mult", 1.0)) * max(float(fish.get("reel_quality", 0.0)), 0.1) * float(fish.get("filet_mult", 1.0))
	value_label.text = "$%.2f" % estimated
	stars_label.text = "*" * int(round(float(fish.get("reel_quality", 0.0)) * 5.0))
	panel.modulate = Color(1.0, 0.9, 0.4) if fish.get("id", "") == "midnight_leviathan" else Color.WHITE
	panel.position.x = 1080.0
	var tween := create_tween()
	tween.tween_property(panel, "position:x", 760.0, 0.25)
	tween.tween_interval(2.0)
	tween.tween_property(panel, "position:x", 1080.0, 0.25)
	await tween.finished
	queue_free()
