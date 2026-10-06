extends ExplodingProjectile

@export var max_damage: float = 100.0
@export var full_damage_radius: float = 2.0
@export var falloff_radius: float = 6.0

func _on_explosion(targets: Array):
	var last_pos: Vector3 = global_position + global_basis.z * 0.5
	
	var vfx = VFX.new("explosion", last_pos + Vector3(0, 0.05, 0))
	Globals.world.add_child(vfx)
	vfx.restart()
	
	var audio = Audio3D.new("guns/projectile_contact", last_pos)
	audio.max_db = 15.0
	audio.play()
	
	for target in targets:
		if target is Humanoid:
			var dist: float = target.global_position.distance_to(last_pos)
			var damage: float = _calculate_damage(dist)
			
			target.hurt(damage, DamageInfo.new("forceful", projectile_owner))
			knockback_target(target)
			
	on_blast_hit.emit(targets)

func _calculate_damage(dist: float) -> float:
	if dist <= full_damage_radius:
		return max_damage
	if dist >= falloff_radius:
		return 0.0
	# linear falloff between full_damage_radius and falloff_radius
	var t: float = (dist - full_damage_radius) / (falloff_radius - full_damage_radius)
	return lerp(max_damage, 0.0, t)

func knockback_target(target: Humanoid):
	var basisVec = global_position + global_basis.z
	var dir: Vector3 = basisVec.direction_to(target.global_position)
	var force: float = 10
	
	var launchVec: Vector3 = dir * force
	launchVec.y = min(launchVec.y, 0.5)
	
	target.knockback(launchVec)
