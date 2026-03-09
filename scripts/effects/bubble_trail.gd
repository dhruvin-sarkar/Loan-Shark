extends Node2D

# bubble_trail.gd - Bubble trail effect

@onready var particles: GPUParticles2D = $Particles2D

func _ready():
	particles.emitting = true

func start():
	particles.emitting = true

func stop():
	particles.emitting = false
