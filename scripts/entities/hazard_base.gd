extends Area2D

# hazard_base.gd - Base hazard behavior (GDD v3.0 compliant)

signal hazard_triggered(player: Node2D)
signal hazard_despawned()

@export var hazard_type: String = "jellyfish"  # jellyfish, shark, eel, octopus, turtle, undertow
@export var damage: int = 20
@export var speed: float = 30.0
@export var stun_duration: float = 0.0  # Some hazards stun

var is_active: bool = true
var movement_direction: Vector2 = Vector2.LEFT

@onready var sprite: Sprite2D = $Sprite2D
@onready var warning_timer: Timer = $WarningTimer

func _ready():
	body_entered.connect(_on_body_entered)
	warning_timer.timeout.connect(_despawn)

func _process(delta):
	if is_active:
		_move(delta)

func _move(delta):
	position += movement_direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("hazard_triggered", body)
		_apply_damage(body)

func _apply_damage(player: Node2D):
	# Apply hazard effect based on type
	match hazard_type:
		"jellyfish":
			# Stun player briefly
			if player.has_method("stun"):
				player.stun(2.0)
		"shark":
			# High damage - ends fishing session
			if player.has_method("take_damage"):
				player.take_damage(damage)
		"eel":
			# Medium damage + brief stun
			if player.has_method("stun"):
				player.stun(1.0)
			if player.has_method("take_damage"):
				player.take_damage(damage / 2)
		"octopus":
			# Ink cloud - reduces visibility
			if player.has_method("apply_ink"):
				player.apply_ink(3.0)
		"turtle":
			# Non-aggressive - gives coin bonus if avoided
			pass
		"undertow":
			# Pulls player in direction
			if player.has_method("apply_drift"):
				player.apply_drift(movement_direction, 2.0)

func _despawn():
	emit_signal("hazard_despawned")
	queue_free()

func set_direction(dir: Vector2):
	movement_direction = dir.normalized()
