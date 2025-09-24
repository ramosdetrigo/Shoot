extends Gun


signal ammo_changed(ammo_left: int)


func _ready() -> void:
	%FireTimer.wait_time = fire_cooldown
	%ReloadTimer.wait_time = reload_cooldown


func handle_firing() -> void:
	if Input.is_action_just_pressed("reload"):
		reload()
	
	if Input.is_action_just_pressed("shoot") and %ReloadTimer.time_left < 0.1:
		shoot_queued = true
	
	if can_shoot and (shoot_queued or (auto_shoot and Input.is_action_pressed("shoot"))):
		shoot_queued = false
		can_shoot = false
		var bullet = Global.create_bullet(%FirePosition.global_position)
		bullet.linear_velocity = Vector2(bullet_speed, 0.0).rotated(rotation)
		set_ammo(current_ammo - 1)
		
		if current_ammo == 0:
			reload()
		else:
			%FireTimer.start()


func reload() -> void:
	%ReloadTimer.start()
	reloading = true
	can_shoot = false


func _on_reload_timer_timeout() -> void:
	reloading = false
	can_shoot = true
	set_ammo(max_ammo)


func _on_fire_timer_timeout() -> void:
	can_shoot = true


func set_ammo(quantity: int) -> void:
	current_ammo = quantity
	ammo_changed.emit(current_ammo)
