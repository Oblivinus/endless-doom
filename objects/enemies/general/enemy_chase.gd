class_name EnemyChaseState extends State

func process_physics(delta: float):
	var target_pos := parent.target.global_position
	var distance = parent.global_position.distance_to(target_pos)
	
	if distance > parent.detection_range:
		parent.stop_move_to()
		transitioned.emit(self, "idle")
	
	parent.move_to(target_pos)
	parent.change_move_to_direction(target_pos)
	
	if distance <= parent.attack_range:
		parent.stop_move_to()
		transitioned.emit(self, "attack")
		
