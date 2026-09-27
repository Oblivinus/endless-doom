class_name PinkyAttackState extends EnemyAttackState

func _on_attack() -> void:
	Audio3D.new("pinky/pinky_attack", parent).play()

func melee_attack() -> void:
	if parent.is_dead or is_disturbed: return
	var humanoid: Humanoid = _check_for_target_in_melee()
	if humanoid:
		humanoid.hurt(parent.melee_damage)

func switch_to_chase() -> bool:
	if strafing or parent.is_moving or parent.is_on_cooldown(): return false
	return super()

func strafe() -> void:
	if strafe_timer.is_stopped(): strafing = false
	if not parent.is_on_cooldown() or parent.is_attacking: return
	if strafing or parent.is_moving: return
	
	if not strafing and not parent.is_moving:
		strafing = true
		strafe_timer.wait_time = 0.15
		strafe_timer.start()
		
		var away_dir = parent.target.global_position.direction_to(parent.global_position)
		away_dir.y = 0
		away_dir = away_dir.normalized()
		
		var angle_offset = [-80, 80]
		away_dir = away_dir.rotated(Vector3.UP, angle_offset.pick_random())
		
		var retreat_distance = randf_range(3, 5)
		var target_pos = parent.global_position + away_dir * retreat_distance
		parent.move_to(target_pos)
