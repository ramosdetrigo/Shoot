class_name Bullet
extends RigidBody2D

const POOF: PackedScene = preload("res://scenes/effects/poof/poof_particles.tscn")

@export
var damage: float = 2.0
@export
var lifetime: float = 3.0

var player_owned: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%LifetimeTimer.wait_time = lifetime
	%LifetimeTimer.start()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("hittable"):
		if body is Robot and player_owned != body.is_player:
			body.hit(damage)
			queue_free()
	else:
		queue_free()
		spawn_poof()


func _on_lifetime_timer_timeout() -> void:
	spawn_poof()
	queue_free()


func spawn_poof() -> void:
	var poof: CPUParticles2D = POOF.instantiate()
	poof.position = position
	Global.arena.add_child(poof)
