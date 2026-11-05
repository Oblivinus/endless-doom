class_name PlasmaBolt extends HomingProjectile

@export var max_pierce: int = 3
@export var delay_homing: float = 0.1
var pierced: int = 0
var _delay: float

func _on_pool_spawn() -> void:
	super()
	pierced = 0

func launch(direction: Vector3) -> void:
	_delay = delay_homing
	super(direction)

func _physics_process(delta: float) -> void:
	if _delay > 0:
		_delay -= delta
		enable_following = false
	else:
		enable_following = true
	
	super(delta)

func  _on_hit(other: Node3D):
	var last_pos: Vector3 = global_position
	var vfx = VfxConstructor.new("plasma_bolt_hit")
	vfx.one_shot = true
	var vfx_pos = last_pos + (-_heading)
	vfx.restart_at(vfx_pos)
	
	if other is Humanoid:
		on_hit.emit(other)
		stop_follow()
		pierced += 1
		if pierced < max_pierce: return
	
	super(other)
