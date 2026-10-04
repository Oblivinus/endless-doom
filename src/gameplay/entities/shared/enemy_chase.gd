class_name EnemyChaseState extends State

var target_pos: Vector3

func process_physics(delta: float):
	if not parent.target:
		transitioned.emit(self, "idle")
		return
	
	var distance = parent.global_position.distance_to(target_pos)
	target_pos = parent.target.global_position
	
	var attack_range_valid: bool = distance <= parent.attack_range and parent.attack_range > 0.0
	var melee_range_valid: bool = distance <= parent.melee_range and parent.melee_range > 0.0
	
	if distance > parent.detection_range * 4:
		_on_outside_range()
		parent.stop_move()
		transitioned.emit(self, "idle")
		parent.target = null
		return
	
	if attack_range_valid or melee_range_valid:
		_on_inside_range()
		parent.stop_move()
		transitioned.emit(self, "attack")
	else:
		_on_outside_attack_range()

func _on_outside_range() -> void:
	pass

func _on_inside_range() -> void:
	pass

func _on_outside_attack_range() -> void:
	parent.move(target_pos)
