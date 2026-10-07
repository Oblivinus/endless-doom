class_name Shotgun extends Gun


func shoot() -> void:
	if not ready_to_shoot(): return
	super()
	create_spread_bullet_hit(last_hit_count)

func hurt_enemy(enemy: Enemy) -> void:
	var min_damage: float = damage * 0.5
	var min_distance = 7
	
	var distance: float = global_position.distance_to(enemy.global_position)
	var t: float = clamp((distance - min_distance) / (max_range - min_distance), 0, 1)
	var applied_dmg = lerp(damage, min_damage, t)
	
	var knock_force = global_position.direction_to(enemy.global_position) * 5
	
	enemy.hurt(applied_dmg, get_damage_info())
	enemy.knockback(knock_force)

func create_spread_bullet_hit(hit_count: int):
	var pellets_remaining: int = 10 - hit_count
	for i in range(pellets_remaining):
		var dir: Vector3 = _random_spread_direction()
		var target: Vector3 = global_position + dir * max_range
		create_bullet_hit_ray(target)

func _random_spread_direction() -> Vector3:
	var forward: Vector3 = (global_basis * Vector3.FORWARD).normalized()
	var h_angle: float = deg_to_rad(randf_range(-10, 10))
	var v_angle: float = deg_to_rad(randf_range(-10, 10))

	var dir: Vector3 = forward.rotated(global_basis.y.normalized(), h_angle)
	dir = dir.rotated(global_basis.x.normalized(), v_angle)
	return dir.normalized()
