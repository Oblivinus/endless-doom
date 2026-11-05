class_name DamageProjectile extends Projectile

@export var damage_range: Array[float] = [20.0, 3.0, 1.0]
@export var damage: float = 1.0:
	get():
		return CombatManager.roll_damage_range(damage_range)

var damage_info: CombatManager.CombatInfo

func  _on_hit(other: Node3D):
	super(other)
	
	if not other or not other is Humanoid: return
	var hum: Humanoid = other
	
	hum.hurt(damage, get_combat_info())

func get_combat_info() -> CombatManager.CombatInfo:
	if damage_info != null: return damage_info
	else: return CombatManager.CombatInfo.new()
