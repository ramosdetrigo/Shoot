class_name Gun extends Sprite2D

@export
var bullet_speed: float = 450.0
@export
var fire_cooldown: float = 0.4
@export
var reload_cooldown: float = 1.0
@export
var max_ammo: int = 16
@export
var current_ammo: int = max_ammo
@export
var auto_shoot: bool = false


var can_shoot: bool = true
var reloading: bool = false
var shoot_queued: bool = false

func handle_firing() -> void:
	pass
