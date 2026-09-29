class_name EnemyAttackState extends State

var ready_to_attack := false
var attacking := false

var strafe_timer: Timer

var strafing := false
var dist_to_target: float = 0.0

func  _ready() -> void:
	strafe_timer = Timer.new()
	strafe_timer.one_shot = true
	strafe_timer.wait_time = 0.35
	add_child(strafe_timer)

func process_physics(_delta: float) -> void:
	if not parent.target: 
		transitioned.emit(self, "idle")
		return
	
	_check_distance()
	var strafe_condition = _strafe_condition()
	
	if not check_if_target_valid(): 
		parent.target = null
		return
	if check_if_in_range(): 
		ready_to_attack = true
		if strafe_condition: strafe()
	else:
		ready_to_attack = false
		chase()
		return
	
	if ready_to_attack:
		parent.attack_at_position(parent.target.global_position)

func _check_distance() -> void:
	if not parent.target: 
		dist_to_target = 0.0
		return 
	dist_to_target = parent.global_position.distance_to(parent.target.global_position)

func _strafe_condition() -> bool:
	if strafe_timer.is_stopped(): strafing = false
	if not parent.is_on_cooldown() or parent.is_attacking: return false
	if strafing or parent.is_moving: return false
	return true

func check_if_target_valid() -> bool:
	return not parent.target.is_dead

func check_if_in_detection_range():
	return dist_to_target <= parent.detection_range

func check_if_in_range() -> bool:
	var attack_range_valid: bool = dist_to_target <= parent.attack_range and parent.has_range
	var melee_range_valid: bool = dist_to_target <= parent.melee_range and parent.has_melee
	return attack_range_valid or melee_range_valid

func strafe() -> void:
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

func chase():
	transitioned.emit(self, "chase")

func on_missed_or_blocked(block_pos: Vector3 = Vector3.ZERO) -> void:
	pass
