class_name Shotgun extends Gun

var min_damage: float
var min_distance: float
var max_hit_count_distance: float = 1.5
var min_hit_count_distance: float

func _ready() -> void:
	super()
	min_damage = damage * 0.3
	min_distance = 2
	min_hit_count_distance = max_range * 1/3

func _check_and_shoot() -> void:
	last_hit_count = 0
	
	var enemies = hitbox.get_overlapping_bodies()
	enemies.sort_custom(func(a: Node3D, b: Node3D): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	if enemies.is_empty(): return
	
	var check_count = 0
	for enemy: Enemy in enemies:
		var query = _check_ray_cast(enemy.global_position)
		if query.is_empty():
			hurt_enemy(enemy)
			if enemy.is_dead: parent.register_kill(enemy)
		else:
			create_bullet_hit(query.position)
		
		var enemy_distance = global_position.distance_to(enemy.global_position)
		
		var hit_cost: int = roundi( Util.value_falloff_distance(enemy_distance, max_hit, 1, max_hit_count_distance, min_hit_count_distance) )
		check_count += hit_cost
		last_hit_count += 1
		
		if check_count >= max_hit:
			break

func _get_hit_cost(distance: float) -> int:
	var t: float = clamp(
		(distance - max_hit_count_distance) / (min_hit_count_distance - max_hit_count_distance),
		0.0, 1.0)
	return roundi(lerp(float(max_hit), 1.0, t))

func shoot() -> void:
	if not ready_to_shoot(): return
	super()
	create_spread_bullet_hit(last_hit_count)

func hurt_enemy(enemy: Enemy) -> void:
	var distance: float = global_position.distance_to(enemy.global_position)
	var applied_dmg = Util.value_falloff_distance(distance, damage, min_damage, min_distance, max_range)
	
	enemy.hurt(applied_dmg, get_damage_info())
	knockback_enemy(distance, enemy)

func knockback_enemy(distance: float, enemy: Enemy):
	var magnitude: float = 5
	var applied_force_magnitude: float = Util.value_falloff_distance(distance, magnitude, 3.5, max_hit_count_distance, max_range/2)
	var knock_force = global_position.direction_to(enemy.global_position) * applied_force_magnitude
	
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
