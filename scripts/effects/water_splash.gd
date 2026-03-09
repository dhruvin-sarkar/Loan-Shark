extends Node2D

# water_splash.gd - Water splash effect

@onready var particles: GPUParticles2D = $Particles2D

func _ready():
	particles.emitting = true
	particles.finished.connect(queue_free)

func play_at(pos: Vector2):
	global_position = pos
	particles.emitting = true
