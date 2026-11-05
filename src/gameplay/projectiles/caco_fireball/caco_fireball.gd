class_name CacodemonFireball extends DamageProjectile

func _on_hit(other: Node3D):
	var last_pos = global_position
	super(other)
	
	var vfx = VfxConstructor.new("caco_fireball_explosion")
	vfx.one_shot = true
	vfx.restart_at(last_pos)
