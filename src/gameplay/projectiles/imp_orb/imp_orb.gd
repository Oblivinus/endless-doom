class_name ImpOrb extends Projectile

@export var damage: float

func  _on_hit(other: Node3D):
	super(other)
	var last_pos: Vector3 = global_position
	var vfx: VFX = VFX.new("imp_orb_explosion", last_pos)
	Globals.world.add_child(vfx)
	vfx._one_shot = true
	vfx.restart()
	
	if not other or not other is Humanoid: return
	
	var hum: Humanoid = other
	if not hum is Humanoid: return
	
	hum.hurt(damage)
