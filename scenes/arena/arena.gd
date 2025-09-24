class_name Arena extends Node2D

@onready
var blood_particle_holder: Node2D = %BloodParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.arena = self
