extends Node2D

# coin_particle.gd - Coin particle effect

@onready var particles: GPUParticles2D = $Particles2D

func _ready():
	particles.emitting = true
	particles.finished.connect(queue_free)

func play_at(pos: Vector2, amount: int = 5):
	global_position = pos
	particles.amount = amount
	particles.emitting = true
