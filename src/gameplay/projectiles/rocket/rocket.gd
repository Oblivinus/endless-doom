extends ExplodingProjectile

@export var max_damage: float = 100.0
@export var full_damage_radius: float = 2.0
@export var falloff_radius: float = 6.0

#func _ready() -> void:
	#super()
	#on_blast_hit.connect(test)

func _on_explosion(targets: Array):
	var last_pos: Vector3 = global_position
	
	var vfx = VFX.new("explosion", last_pos + Vector3(0, 0.05, 0))
	Globals.world.add_child(vfx)
	vfx.restart()
	
	var audio = Audio3D.new("guns/projectile_contact", last_pos)
	audio.max_db = 15.0
	audio.play()
	
	for target: Humanoid in targets:
		if target is Humanoid:
			var dist: float = target.global_position.distance_to(last_pos)
			var damage: float = _calculate_damage(dist)
			target.hurt(damage)
	on_blast_hit.emit(targets)

func _calculate_damage(dist: float) -> float:
	if dist <= full_damage_radius:
		return max_damage
	if dist >= falloff_radius:
		return 0.0
	# linear falloff between full_damage_radius and falloff_radius
	var t: float = (dist - full_damage_radius) / (falloff_radius - full_damage_radius)
	return lerp(max_damage, 0.0, t)

func test(a):
	print(a)
