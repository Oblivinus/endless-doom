class_name EnemyAttackState extends State

var ready_to_attack := false
var attacking := false

var strafe_timer: Timer

var strafing := false
var strafe_direction_angle: Array[int] = [0, 90, -90, -180]
var dist_to_target: float = 0.0

func enter() -> void:
	parent.stop_move()

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
	
	if _is_target_escape():
		parent.target = null
		return
	
	if _is_target_in_range():
		ready_to_attack = true
	else:
		ready_to_attack = false
		if _chase_condtion(): chase()
	
	if _strafe_condition(): strafe()
	
	if ready_to_attack:
		parent.attack_at_position(parent.target.global_position)

func _check_distance() -> void:
	if not parent.target: 
		dist_to_target = 0.0
		return 
	dist_to_target = parent.global_position.distance_to(parent.target.global_position)

func _is_target_in_range() -> bool:
	if dist_to_target <= parent.get_max_range(): return true
	else: return false

func _is_target_escape() -> bool:
	if dist_to_target < parent.detection_range + 20: return false
	return true

func _chase_condtion() -> bool:
	if parent.is_on_cooldown(): return false
	if dist_to_target <= parent.get_max_range(): return false
	
	return true

func chase():
	transitioned.emit(self, "chase")

func strafe() -> void:
	if not strafing and not parent.is_moving:
		strafing = true
		strafe_timer.start()
		
		var away_dir = parent.target.global_position.direction_to(parent.global_position)
		away_dir.y = 0
		away_dir = away_dir.normalized()
		
		var angle_offset = strafe_direction_angle.pick_random()
		away_dir = away_dir.rotated(Vector3.UP, angle_offset)
		
		var retreat_distance = randf_range(1, 3)
		var target_pos = parent.global_position + away_dir * retreat_distance
		parent.move_to(target_pos)

func _strafe_condition() -> bool:
	if strafe_timer.is_stopped(): strafing = false
	if not parent.is_on_cooldown(): return false
	if parent.is_attacking: return false
	if strafing or parent.is_moving: return false
	
	return true
