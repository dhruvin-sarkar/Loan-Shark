extends Control

# filet_minigame.gd - Filleting minigame controller

signal filet_completed(materials: Array)

var cut_points: Array = []
var current_fish: Resource = null
var is_active: bool = false

@onready var fish_display: TextureRect = $FishDisplay
@onready var cut_line: Line2D = $CutLine
@onready var result_label: Label = $ResultLabel

func _ready():
	_setup_cut_points()

func _setup_cut_points():
	# Define cut points for the fish
	for i in range(5):
		var point = Marker2D.new()
		point.position = Vector2(randf_range(50, 150), randf_range(50, 150))
		cut_points.append(point)

func _input(event):
	if is_active and event is InputEventMouseButton:
		if event.pressed:
			_add_cut_point(event.position)

func _add_cut_point(pos: Vector2):
	cut_line.add_point(pos)
	_check_cut_completion()

func _check_cut_completion():
	if cut_line.points.size() >= 5:
		var materials = _calculate_materials()
		filet_completed.emit(materials)
		stop_minigame()

func _calculate_materials() -> Array:
	var results = []
	if current_fish:
		# Generate materials based on fish type
		results.append({"id": "mat_small_bone", "count": randi_range(1, 3)})
		if randf() > 0.5:
			results.append({"id": "mat_shell", "count": 1})
	return results

func start_minigame(fish: Resource):
	current_fish = fish
	is_active = true
	cut_line.clear_points()
	_setup_knife_values()
	show()

var sharpness_zone: float = 5.0  # Pixels
var qte_window: float = 0.6  # Seconds
var max_mult: float = 1.2
var knife_id: String = ""

func _setup_knife_values():
	# Knife-specific values per GDD Section 7
	knife_id = GameState.equipped_knife
	match knife_id:
		"knife_rusty":
			sharpness_zone = 5.0
			qte_window = 0.6
			max_mult = 1.2
		"knife_amateur":
			sharpness_zone = 12.0
			qte_window = 0.9
			max_mult = 1.4
		"knife_pro":
			sharpness_zone = 22.0
			qte_window = 1.3
			max_mult = 1.5
		_:
			# Default to rusty
			sharpness_zone = 5.0
			qte_window = 0.6
			max_mult = 1.2

func _calculate_score() -> float:
	# Calculate filet score based on cut accuracy
	var score = 0.0
	# Score calculation would go here based on how close cuts were to optimal line
	return score

func _on_perfect_filet():
	# Pro knife bonus: drop one random material on perfect score (90-100%)
	if knife_id == "knife_pro":
		var materials = ["mat_shell", "mat_coral", "mat_sea_glass", "mat_driftwood"]
		var random_mat = materials.pick_random()
		GameState.add_material(random_mat, 1)

func stop_minigame():
	is_active = false
	hide()
