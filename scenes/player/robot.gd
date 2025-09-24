class_name Robot
extends CharacterBody2D

const DASH_PARTICLES: PackedScene = preload("res://scenes/effects/dash/dash_particles.tscn")
const BLOOD_PARTICLES: PackedScene = preload("res://scenes/effects/blood/blood_particles.tscn")
const COLOR_PLAYER: Color = Color("#4f8fba")
const COLOR_ENEMY: Color = Color("#a53030")


@export
var move_speed: float = 80.0
@export
var dash_speed: float = 200.0
@export
var dash_time: float = 0.2
@export
var dash_cooldown: float = 0.5
@export
var health: float = 20.0

@export
var is_player: bool = false


var held_gun: Gun
var look_direction: int = 1

var dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2(0,0)


func _ready() -> void:
	%DashTimer.wait_time = dash_time
	%DashCooldown.wait_time = dash_cooldown
	%AnimatedSprite.play("idle")
	held_gun = %Pistol
	
	if is_player:
		%AnimatedSprite.modulate = COLOR_PLAYER
	else:
		%AnimatedSprite.modulate = COLOR_ENEMY
		# Não usamos as luzes e câmera
		%Camera2D.queue_free()
		%PointLight2D.queue_free()


func set_gun(gun: Gun) -> void:
	# Only queue free if it exists and is already added to the tree
	if held_gun != null and held_gun.get_parent() != null:
		held_gun.queue_free()
	
	held_gun = gun
	add_child(gun)


func _process(_delta: float) -> void:
	if not is_player:
		return
	
	var mouse_position = get_local_mouse_position()
	look_direction = sign(mouse_position.x)
	%AnimatedSprite.scale.x = look_direction
	
	# Aponta a arma na direção do mouse e lida com o botão de tiro etc
	held_gun.scale.y = look_direction
	if held_gun.reloading:
		held_gun.position = Vector2(0, -6)
		held_gun.rotation = PI * 1.5
	else:
		held_gun.position = get_local_mouse_position().normalized() * 6
		held_gun.look_at(get_global_mouse_position())
	held_gun.handle_firing()
	
	# Atualiza a animação aqui, ao invés de no processamento de física
	if velocity.is_zero_approx():
		%AnimatedSprite.play("idle")
	else:
		%AnimatedSprite.play("walk")
	
	# Lida com o dash
	if Input.is_action_just_pressed("dash") and can_dash:
		# Inicia o dash
		dash_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if dash_direction.is_zero_approx():
			dash_direction = Vector2(look_direction, 0)
		dashing = true
		%DashTimer.start()
		
		# Desliga o dash até o atual acabar + o cooldown terminar.
		can_dash = false
		
		# Emite as partículas de dash do jogador
		var particle_emitter: CPUParticles2D = DASH_PARTICLES.instantiate()
		%ParticleHolder.add_child(particle_emitter)
		particle_emitter.emitting = true


func _physics_process(_delta: float) -> void:
	if not is_player:
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if dashing:
		velocity = dash_direction * dash_speed + direction * move_speed
	else:
		velocity = direction * move_speed
	move_and_slide()


func _on_dash_timer_timeout() -> void:
	dashing = false
	%DashCooldown.start()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true


func hit(damage: float) -> void:
	health -= damage
	create_tween().tween_method(set_hit_flash_intensity, 1.0, 0.0, 0.2)
	if health <= 0.0:
		hide()
		set_collision_layer_value(2, false)
		var blood: CPUParticles2D = BLOOD_PARTICLES.instantiate()
		blood.position = position
		blood.color = %AnimatedSprite.modulate
		Global.arena.blood_particle_holder.add_child(blood)


func set_hit_flash_intensity(intensity: float) -> void:
	%AnimatedSprite.material.set_shader_parameter("intensity", intensity)
