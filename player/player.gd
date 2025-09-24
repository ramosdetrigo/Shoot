extends CharacterBody2D

const DASH_PARTICLES: PackedScene = preload("res://player/dash_particles.tscn")
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

var look_direction: int = 1

var dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2(0,0)

#var player: bool = false

func _ready() -> void:
	%DashTimer.wait_time = dash_time
	%DashCooldown.wait_time = dash_cooldown
	%AnimatedSprite.play("idle")


func _process(_delta: float) -> void:
	var mouse_position = get_local_mouse_position()
	look_direction = sign(mouse_position.x)
	%AnimatedSprite.scale.x = look_direction
	
	# Atualiza a animação aqui, ao invés de no processamento de física
	if velocity.is_zero_approx():
		%AnimatedSprite.play("idle")
	else:
		%AnimatedSprite.play("walk")
	
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
