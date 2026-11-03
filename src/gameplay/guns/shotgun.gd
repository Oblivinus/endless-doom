class_name Shotgun extends Gun

@export var aim_cone_deg: float = 30.0 

var min_damage: float
var min_distance: float
var max_hit_count_distance: float = 1.5
var min_hit_count_distance: float

func _ready() -> void:
	super()
	min_damage = damage * 0.2
	min_distance = 2
	min_hit_count_distance = max_range * 1/3

func _check_and_shoot() -> void:
	last_hit_count = 0
	
	var enemies = _check_for_valid_enemies()
	
	if enemies.is_empty(): return
	
	var check_count = 0
	for enemy: Enemy in enemies:
		hurt_enemy(enemy)
		
		var enemy_distance = global_position.distance_to(enemy.global_position)
		var hit_cost: int = roundi( Util.value_falloff_distance(enemy_distance, max_hit, 1, max_hit_count_distance, min_hit_count_distance) )
		
		check_count += hit_cost
		last_hit_count += 1
		
		if check_count >= max_hit:
			break

#this one is ai generated, just for temporary. cause the lag is insane
func _check_for_valid_enemies() -> Array[Humanoid]:
	var result: Array[Humanoid] = []
	var origin := global_position
	var fwd := -global_basis.z
	var max_sq := max_range * max_range
	var cos_limit := cos(deg_to_rad(aim_cone_deg))

	var nodes: Array[Humanoid] = []
	var dists: Array[float] = []

	for n in get_tree().get_nodes_in_group("enemies"):
		var h := n as Humanoid
		if h == null or h.is_dead:
			continue
		var to := h.global_position - origin
		var d2 := to.length_squared()
		if d2 > max_sq:
			continue
		if d2 > 0.0001 and fwd.dot(to) < cos_limit * sqrt(d2):
			continue
		var i := dists.bsearch(d2)
		dists.insert(i, d2)
		nodes.insert(i, h)
	
	for h in nodes:
		if _check_ray_cast(h.global_position).is_empty():
			result.append(h)
			if result.size() >= max_hit:
				break
	return result

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
