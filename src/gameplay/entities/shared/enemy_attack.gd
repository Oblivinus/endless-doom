class_name EnemyAttackState extends State

@export var shot_vfx: AudioStream

var on_cooldown := false
var ready_to_attack := false
var attacking := false
var is_disturbed := false

var strafing := false
var strafe_timer := 0.0

func process_physics(delta: float):
	if not parent.target: return
	if parent.is_hurted: is_disturbed = true
	var distance = parent.global_position.distance_to(parent.target.global_position)
	
	if distance > parent.detection_range or parent.target.is_dead:
		transitioned.emit(self, "idle")
		parent.target = null
		return
	
	if on_cooldown and not attacking:
		_strafe(delta)
	
	if distance <= parent.attack_range:
		ready_to_attack = true
	elif not attacking:
		transitioned.emit(self, "chase")
		return
	
	if ready_to_attack and not on_cooldown:
		parent.stop_move()
		attacking = true
		on_cooldown = true
		parent.look_at(Globals.player.global_position)
		parent.on_attack.emit()
		get_tree().create_timer(0.7).timeout.connect(attack)
		
		await get_tree().create_timer(parent.attack_cd).timeout
		on_cooldown = false
		is_disturbed = false

func _strafe(delta: float) -> void:
	strafe_timer += delta
	if strafe_timer >= 0.35:
		strafe_timer = 0.0
		strafing = false
	
	if not strafing and not parent.is_moving:
		strafing = true
		
		var away_dir = parent.target.global_position.direction_to(parent.global_position)
		away_dir.y = 0
		away_dir = away_dir.normalized()
		
		var angle_offset = [-80, 80]
		angle_offset = angle_offset[randi_range(0, angle_offset.size() - 1)]
		away_dir = away_dir.rotated(Vector3.UP, angle_offset)
		
		var retreat_distance = randf_range(1, 1.5)
		var target_pos = parent.global_position + away_dir * retreat_distance
		parent.move_to(target_pos)

func _check_for_target() -> Humanoid:
	var targets = parent.hitbox.get_overlapping_bodies()
	if targets.is_empty(): return null
	
	for humanoid: Humanoid in targets:
		var query = _raycast_check(humanoid.global_position)
		if query.is_empty():
			return humanoid
		else:
			var intersect: Vector3 = query.position
			var vfx = VFX.new("bullet_hit", intersect)
			Globals.world.add_child(vfx)
			vfx.global_basis = parent.global_basis
			vfx.restart()
	return null

func _raycast_check(final_pos: Vector3):
	var space_state = parent.get_world_3d().direct_space_state
	
	var origin = parent.global_position
	var query = PhysicsRayQueryParameters3D.create(origin, final_pos)
	query.collision_mask = (1 << 1)
	
	var result = space_state.intersect_ray(query)
	return result

func attack():
	ready_to_attack = false
	attacking = false
	
	if parent.is_dead or is_disturbed: return
	$"../../OmniLight3D".visible = true
	Audio3dManager.play_sound_at_position(shot_vfx, parent)
	var humanoid: Humanoid = _check_for_target()
	if humanoid:
		humanoid.hurt(parent.attack_damage)
	await get_tree().create_timer(0.1).timeout
	$"../../OmniLight3D".visible = false
