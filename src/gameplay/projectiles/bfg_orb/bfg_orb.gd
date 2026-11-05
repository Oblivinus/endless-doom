class_name BfgOrb extends ExplodingProjectile

@export var max_damage: float
@export var tracer_damage: float
@export var max_hit: int = 5

var hit_count: int = 0
var max_reached: bool = false
var has_triggered: bool = false

func _ready() -> void:
	super()
	blast_area.body_entered.connect(_tracer_hit)

func launch(direction: Vector3) -> void:
	hit_count = 0
	max_reached = false
	has_triggered = false
	super(direction)

func _on_explosion(targets: Array):
	var last_pos: Vector3 = global_position + global_basis.z * 0.5
	
	var vfx = VfxConstructor.new("bfg_explosion")
	vfx.restart_at(last_pos + Vector3(0, 0.05, 0))
	
	var audio = GameManager.play_hearable_sound("guns/bfg/bfg_explode", last_pos)
	audio.play()
	
	for target in targets:
		if target is Humanoid:
			_hurt_target(target, max_damage)
			_tracer_vfx(target)
			
	on_blast_hit.emit(targets)

func _hurt_target(target: Humanoid, damage: float):
	var combat_info: CombatManager.CombatInfo = CombatManager.CombatInfo.new("forceful", projectile_owner)
	combat_info.pain_modifier = 2.0
	
	target.hurt(damage, combat_info)

func _tracer_hit(target: Node3D) -> void:
	if not target is Humanoid: return
	if max_reached or has_triggered: return
	
	_tracer_vfx(target, true)
	
	if hit_count >= max_hit:
		max_reached = true
		await get_tree().create_timer(0.25).timeout
		if not is_inside_tree() or has_triggered: return
		_trigger_once()
		return
	
	_hurt_target(target, tracer_damage)
	hit_count += 1

func _trigger_once() -> void:
	if has_triggered: return
	has_triggered = true
	trigger_on_hit()

func _tracer_vfx(target: Humanoid, zap_follow: bool = false):
	if zap_follow:
		VfxConstructor.Line.create_line("zap").node.fire_follow(self, target, 1.0)
	else:
		VfxConstructor.Line.create_line("zap").fire(global_position, target.global_position)
		
	var vfx = VfxConstructor.new("bfg_tracer")
	vfx.position = Vector3.ZERO
	vfx.one_shot = true
	vfx.restart_at(target)
