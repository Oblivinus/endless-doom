class_name EnemyAttackState extends State

@export var shot_vfx: AudioStream
@export var attack_delay: float = 0.7

var on_cooldown := false
var ready_to_attack := false
var attacking := false
var is_disturbed := false

var strafe_timer: Timer
var atk_cd_timer: Timer

var strafing := false
var strafe_timerf := 0.0
var dist_to_target: float = 0.0
var attack_pos: Vector3 = Vector3.ZERO

var has_melee: bool
var has_range: bool

func  _ready() -> void:
	strafe_timer = Timer.new()
	strafe_timer.one_shot = true
	strafe_timer.wait_time = 0.35
	add_child(strafe_timer)

func enter() -> void:
	has_melee = parent.melee_range > 0
	has_range = parent.attack_range > 0

func process_physics(_delta: float) -> void:
	if not parent.target: return
	if parent.in_pain: is_disturbed = true
	
	_check_distance()
	
	if not check_if_target_valid(): return
	if not check_if_in_range(): 
		return
	else:
		strafe()
	
	attack_at_position(parent.target.global_position)

func _check_for_target() -> Humanoid:
	var targets = parent.get_enemies_in_attack_range()
	if targets.is_empty(): return null
	
	for humanoid: Humanoid in targets:
		var query = _raycast_check(humanoid.global_position)
		if query.is_empty():
			return humanoid
		else:
			var intersect: Vector3 = query.position
			on_missed_or_blocked(intersect)
			return
	on_missed_or_blocked()
	return null

func _check_for_target_in_melee() -> Humanoid:
	var targets = parent.get_enemies_in_melee_range()
	if targets.is_empty(): return null
	
	for humanoid: Humanoid in targets:
		var query = _raycast_check(humanoid.global_position)
		if query.is_empty():
			return humanoid
		else:
			var intersect: Vector3 = query.position
			on_missed_or_blocked(intersect)
			return
	on_missed_or_blocked()
	return null

func _raycast_check(final_pos: Vector3) -> Dictionary:
	var raycast = Raycast3d.new(parent)
	raycast.from_to(parent.global_position, final_pos)
	raycast.mask([2])
	var result = raycast.intersect()
	return result

func _on_attack_cooldewn_finish() -> void:
	on_cooldown = false
	is_disturbed = false

func _check_distance() -> void:
	if not parent.target: 
		dist_to_target = 0.0
		return 
	dist_to_target = parent.global_position.distance_to(parent.target.global_position)

func check_if_target_valid() -> bool:
	if dist_to_target > parent.detection_range or parent.target.is_dead:
		transitioned.emit(self, "idle")
		parent.target = null
		return false
	return true

func check_if_in_range() -> bool:
	var attack_range_valid: bool = dist_to_target <= parent.attack_range and parent.attack_range > 0.0
	var melee_range_valid: bool = dist_to_target <= parent.melee_range and parent.melee_range > 0.0
	
	if attack_range_valid or melee_range_valid:
		ready_to_attack = true
		return true
	elif not attacking:
		transitioned.emit(self, "chase")
		return false
	return false

func strafe() -> void:
	if strafe_timer.is_stopped(): strafing = false
	if not on_cooldown or attacking: return
	if strafing or parent.is_moving: return
	
	if not strafing and not parent.is_moving:
		strafing = true
		strafe_timer.start()
		
		var away_dir = parent.target.global_position.direction_to(parent.global_position)
		away_dir.y = 0
		away_dir = away_dir.normalized()
		
		var angle_offset = [-80, 80]
		angle_offset = angle_offset[randi_range(0, angle_offset.size() - 1)]
		away_dir = away_dir.rotated(Vector3.UP, angle_offset)
		
		var retreat_distance = randf_range(1, 1.5)
		var target_pos = parent.global_position + away_dir * retreat_distance
		parent.move_to(target_pos)

func on_missed_or_blocked(block_pos: Vector3 = Vector3.ZERO) -> void:
	pass

func attack_at_position(target_pos: Vector3) -> void:
	var target_no_y := Vector3(target_pos.x, parent.global_position.y, target_pos.z)
	if not ready_to_attack or on_cooldown: return
	parent.stop_move()
	attacking = true
	on_cooldown = true
	attack_pos = target_pos
	
	parent.on_attack.emit()
	parent.look_at(target_no_y)
	
	get_tree().create_timer(attack_delay).timeout.connect(func():
		if not parent.is_dead and not is_disturbed: 
			if has_range and parent.melee_range < dist_to_target:
				attack()
			else:
				melee_attack()
		ready_to_attack = false
		attacking = false
		get_tree().create_timer(parent.attack_cd).timeout.connect(_on_attack_cooldewn_finish)
		)

func attack() -> void:
	pass

func melee_attack() -> void:
	pass
