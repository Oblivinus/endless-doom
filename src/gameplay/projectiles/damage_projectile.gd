class_name DamageProjectile extends Projectile

@export var damage_range: Array[float] = [20.0, 3.0, 1.0]
@export var damage: float = 1.0

func  _on_hit(other: Node3D):
	super(other)
	
	if not other or not other is Humanoid: return
	var hum: Humanoid = other
	
	hum.hurt(damage)
