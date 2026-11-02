class_name ImpOrb extends DamageProjectile

func  _on_hit(other: Node3D):
	super(other)
	
	var last_pos: Vector3 = global_position
	var vfx = VfxConstructor.new("imp_orb_explosion")
	vfx.one_shot = true
	vfx.restart_at(last_pos)
