class_name PlasmaBolt extends HomingProjectile

@export var max_pierce: int = 3
@export var home_delay: float = 0.2
var pierced: int = 0

func _on_pool_spawn() -> void:
	super()
	pierced = 0

func _on_pool_despawn() -> void:
	super()
	_establish_connection(false)

func launch(direction: Vector3) -> void:
	super(direction)
	await get_tree().create_timer(home_delay).timeout
	_establish_connection()

func  _on_hit(other: Node3D):
	var last_pos: Vector3 = global_position
	var vfx = VfxConstructor.new("plasma_bolt_hit")
	vfx.one_shot = true
	var vfx_pos = last_pos + (-_heading)
	vfx.restart_at(vfx_pos)
	
	if other is Humanoid:
		on_hit.emit(other)
		stop_follow()
		_establish_connection()
		pierced += 1
		if pierced < max_pierce: return
	
	super(other)
