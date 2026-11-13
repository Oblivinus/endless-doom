class_name Chaingunner extends Enemy

@export var turn_speed: float = 0.75

var ray: Raycast3d

var max_shot: int = 50
var shot_interval: float = 0.1

func _ready() -> void:
	super()
	
	ray = Raycast3d.new(self)
	ray.mask([2])
	
	if attack_range > 0:
		range_attack_area = _create_range_area(FrustumShape.new(Vector2(0.5, 1), 0, 45, attack_range))
		add_child(range_attack_area)

func _physics_process(delta: float) -> void:
	super(delta)
	
	if is_attacking:
		_facing_follow_target(delta)

func attack_action() -> void:
	for i in range(max_shot):
		if is_disturbed or is_dead: break
		animation_tree.play_attack_anim()
		_shot()
		await get_tree().create_timer(shot_interval).timeout
		if target: attack_pos = target.global_position

func _shot() -> void:
	var humanoid: Humanoid = _check_for_target()
	if humanoid:
		humanoid.hurt(attack_damage)
	
	var far_vect = global_position + (-global_basis.z * attack_range)
	Audio3D.new("guns/pistol", self).play()
	create_bullet_hit_ray(far_vect)

func create_bullet_hit_ray(pos: Vector3):
	ray.from_to(global_position, pos)
	var query = ray.intersect()
	
	if not query.is_empty():
		pos = query.position
		var vfx = VfxConstructor.new("bullet_hit")
		vfx.restart_at(pos)
		vfx.global_basis = global_basis
	
	VfxConstructor.Line.create_line("bullet_line").fire(global_position, pos)

func _facing_follow_target(delta: float) -> void:
	if is_dead: return

	var pos: Vector3
	if target:
		pos = target.global_position
	elif attack_pos != Vector3.ZERO:
		pos = attack_pos
	else:
		return

	var dir := pos - global_position
	dir.y = 0
	if dir.is_zero_approx(): return
	
	var angle := atan2(-dir.x, -dir.z)
	var diff := angle_difference(rotation.y, angle)
	rotation.y += clampf(diff, -turn_speed * delta, turn_speed * delta)
