class_name ImpOrb extends DamageProjectile

func  _on_hit(other: Node3D):
	super(other)
	
	var last_pos: Vector3 = global_position
	var vfx: VFX = VFX.new("imp_orb_explosion", last_pos)
	Globals.world.add_child(vfx)
	vfx._one_shot = true
	vfx.restart()
