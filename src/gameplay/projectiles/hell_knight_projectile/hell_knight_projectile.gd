class_name HellKnightProjectile extends DamageProjectile

func _on_hit(other: Node3D):
	super(other)
	
	var last_pos: Vector3 = global_position
	var vfx = VfxConstructor.new("hell_knight_explosion")
	vfx.one_shot = true
	vfx.restart_at(last_pos)
