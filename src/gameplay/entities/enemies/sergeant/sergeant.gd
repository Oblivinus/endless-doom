class_name Sergeant extends Enemy

var ray: Raycast3d

func _ready() -> void:
	super()
	
	ray = Raycast3d.new(self)
	ray.mask([2])
	
	if attack_range > 0:
		range_attack_area = _create_range_area(FrustumShape.new(Vector2(0.5, 1), 25, 45, attack_range))
		add_child(range_attack_area)

func _on_missed_or_blocked(pos: Vector3 = Vector3.ZERO, _context: String = "none") -> void:
	if pos == Vector3.ZERO: return
	var vfx = VfxConstructor.new("bullet_hit")
	vfx.restart_at(pos)
	vfx.global_basis = global_basis

func attack_action() -> void:
	if is_dead: return
	Audio3D.new("guns/shotgun", self).play()
	
	create_spread_bullet_hit()
	
	var humanoid: Humanoid = _check_for_target()
	if humanoid:
		humanoid.hurt(attack_damage)

func create_spread_bullet_hit():
	for i in range(6):
		var dir: Vector3 = _random_spread_direction()
		var target_pos: Vector3 = global_position + dir * (attack_range * 3)
		create_bullet_hit_ray(target_pos)

func _random_spread_direction() -> Vector3:
	var forward: Vector3 = (global_basis * Vector3.FORWARD).normalized()
	var h_angle: float = deg_to_rad(randf_range(-25, 25))
	var v_angle: float = deg_to_rad(randf_range(-10, 10))

	var dir: Vector3 = forward.rotated(global_basis.y.normalized(), h_angle)
	dir = dir.rotated(global_basis.x.normalized(), v_angle)
	return dir.normalized()

func create_bullet_hit_ray(pos: Vector3):
	ray.from_to(global_position, pos)
	var query = ray.intersect()
	
	if not query.is_empty():
		pos = query.position
		var vfx = VfxConstructor.new("bullet_hit")
		vfx.restart_at(pos)
		vfx.global_basis = global_basis
	
	VfxConstructor.Line.create_line("bullet_line").fire(global_position, pos)
