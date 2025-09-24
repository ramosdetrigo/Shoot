extends Node

const BULLET: PackedScene = preload("res://scenes/guns/base_gun/bullet.tscn")


var arena: Arena


func create_bullet(global_pos: Vector2, player_owned: bool = true) -> Bullet:
	var bullet: Bullet = BULLET.instantiate()
	bullet.player_owned = player_owned
	bullet.global_position = global_pos
	arena.add_child(bullet)
	return bullet
