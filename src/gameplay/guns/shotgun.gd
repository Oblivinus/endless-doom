class_name Shotgun extends Gun

func shoot() -> void:
	if not ready_to_shoot(): return
	super()
	var sfx = Audio3D.new("guns/shotgun", self)
	sfx.play()
	create_spread_bullet_hit(last_hit_count)
	
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
