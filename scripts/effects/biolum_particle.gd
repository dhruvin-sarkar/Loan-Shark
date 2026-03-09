extends Node2D

# biolum_particle.gd - Bioluminescent particle effect

@onready var particles: GPUParticles2D = $Particles2D

func _ready():
	particles.emitting = true

func set_intensity(value: float):
	particles.amount_ratio = value
