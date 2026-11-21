class_name BfgOrb extends ExplodingProjectile

@export var max_damage: float
@export var tracer_damage: float
@export var max_tracer: int = 5
@export var tracer_tick: float = 0.1

var tracer_hit_total: int = 5

var _queue: Array[Humanoid]= []
var _in_effect_dict: Dictionary[Humanoid, bool]= {}

signal on_tracer_hit(target: Humanoid)

func _ready() -> void:
	super()
	blast_area.body_entered.connect(_queue_target)

func _on_pool_spawn() -> void:
	_queue.clear()
	stop_all()

func _on_explosion(targets: Array):
	super(targets)
	
	stop_all()
	var vfx = VfxConstructor.new("bfg_explosion")
	vfx.restart_at(global_position)
	
	var anchor = Node3D.new()
	GameManager.world.add_child(anchor)
	anchor.global_position = global_position
	_anchor_lifetime(anchor)
	
	for target in targets:
		if not target is Humanoid: continue
		start_out_queue_dot(target, anchor)

func _physics_process(delta: float) -> void:
	while _queue.size() > 0 and _in_effect_dict.size() < max_tracer:
		var candidate: Humanoid = _queue.pop_front()
		if not is_instance_valid(candidate): continue
		if _end_tracer_condition(candidate): continue
		start_dot(candidate)

func _queue_target(target: Node3D) -> void:
	if not target is Humanoid: return
	_queue.append(target)

func _end_tracer_condition(target: Humanoid) -> bool:
	var dead: bool = target.is_dead
	var finisher: bool = false
	
	if target is Enemy:
		finisher = target.finisher_ready
	
	return dead or finisher

func start_dot(target: Humanoid) -> void:
	_in_effect_dict[target] = true
	
	for i in range(tracer_hit_total):
		tracer_hit(target)
		if not _in_effect_dict.get(target, false): break
		if _end_tracer_condition(target): break
		await get_tree().create_timer(tracer_tick, false).timeout
	
	stop_tracer_for(target)

func start_out_queue_dot(target: Humanoid, anchor: Node3D = null) -> void:
	for i in range(tracer_hit_total):
		tracer_hit(target)
		if not is_instance_valid(target): break
		if _end_tracer_condition(target): break
		await get_tree().create_timer(tracer_tick, false).timeout

func tracer_hit(target: Humanoid, anchor: Node3D = null) -> void:
	if anchor == null: anchor = self
	VfxConstructor.Line.create_line("zap").node.fire_follow(anchor, target, 0.075)
	
	on_tracer_hit.emit(target)
	
	var vfx = VfxConstructor.new("bfg_tracer")
	vfx.position = Vector3.ZERO
	vfx.one_shot = true
	vfx.restart_at(target)

func stop_tracer_for(target: Humanoid) -> void:
	if not _in_effect_dict.has(target): return
	_in_effect_dict.erase(target)

func stop_all() -> void:
	_queue.clear()
	_in_effect_dict.clear()

func _anchor_lifetime(node: Node3D) -> void:
	await get_tree().create_timer(5, false).timeout
	if is_instance_valid(node): node.queue_free()
