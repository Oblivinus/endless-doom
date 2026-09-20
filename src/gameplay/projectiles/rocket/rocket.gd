extends ExplodingProjectile

@export var max_damage: float = 100.0
@export var full_damage_radius: float = 2.0
@export var falloff_radius: float = 7.5  # distance at which damage reaches 0


func _on_explosion(targets: Array):
	var last_pos: Vector3 = global_position
	var audio = Audio3D.new("guns/projectile_contact", last_pos)
	audio.max_db = 15.0
	audio.play()
	for target: Humanoid in targets:
		if target is Humanoid:
			var dist: float = target.global_position.distance_to(last_pos)
			var damage: float = _calculate_damage(dist)
			target.hurt(damage)

func _calculate_damage(dist: float) -> float:
	if dist <= full_damage_radius:
		return max_damage
	if dist >= falloff_radius:
		return 0.0
	# linear falloff between full_damage_radius and falloff_radius
	var t: float = (dist - full_damage_radius) / (falloff_radius - full_damage_radius)
	return lerp(max_damage, 0.0, t)
