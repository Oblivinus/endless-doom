class_name PlayerRocket extends ExplodingProjectile

@export var damage_range: Array[float] = [20, 3, 1.0]
@export var full_damage_radius: float = 2.0
@export var falloff_radius: float = 6.0

var absolute_damage: float = -1

func _on_explosion(targets: Array):
	var last_pos: Vector3 = global_position + global_basis.z * 0.5
	
	var vfx = VfxConstructor.new("explosion")
	vfx.restart_at(last_pos + Vector3(0, 0.05, 0))
	
	var audio = GameManager.play_hearable_sound("guns/projectile_contact", last_pos)
	audio.play()
	
	for target in targets:
		if target is Humanoid:
			var dist: float = target.global_position.distance_to(last_pos)
			var damage: float = _calculate_damage(dist)
			
			target.hurt(damage, CombatManager.CombatInfo.new("forceful", projectile_owner))
			knockback_target(target)
			
	on_blast_hit.emit(targets)

func _calculate_damage(dist: float) -> float:
	var damage = CombatManager.roll_damage_range(damage_range)
	
	if absolute_damage >= 0:
		damage = absolute_damage
	
	if dist <= full_damage_radius:
		return damage
	if dist >= falloff_radius:
		return 0.0
	# linear falloff between full_damage_radius and falloff_radius
	var t: float = (dist - full_damage_radius) / (falloff_radius - full_damage_radius)
	return lerp(damage, 0.0, t)

func knockback_target(target: Humanoid):
	var basisVec = global_position + global_basis.z
	var dir: Vector3 = basisVec.direction_to(target.global_position)
	var force: float = 10
	
	var launchVec: Vector3 = dir * force
	launchVec.y = min(launchVec.y, 0.5)
	
	if target is Player:
		launchVec = launchVec / 2
	
	target.knockback(launchVec)
