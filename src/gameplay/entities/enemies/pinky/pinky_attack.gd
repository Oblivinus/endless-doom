class_name PinkyAttackState extends EnemyAttackState

func chase():
	if (parent.is_on_cooldown() and parent.is_moving) and check_if_in_detection_range(): return
	super()

func strafe() -> void:
	if not strafing and not parent.is_moving:
		strafing = true
		strafe_timer.wait_time = 0.15
		strafe_timer.start()
		
		var away_dir = parent.target.global_position.direction_to(parent.global_position)
		away_dir = away_dir.normalized()
		
		var angle_offset = [-45, 45, 20, -20]
		away_dir = away_dir.rotated(Vector3.UP, angle_offset.pick_random())
		
		var retreat_distance = randf_range(3, 5)
		var target_pos = parent.global_position + away_dir * retreat_distance
		parent.move(target_pos)
