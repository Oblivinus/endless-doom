class_name EnemyChaseState extends State

var target_pos: Vector3

func process_physics(delta: float):
	if not parent.target:
		transitioned.emit(self, "idle")
		return
	
	var distance = parent.global_position.distance_to(target_pos)
	target_pos = parent.target.global_position
	
	if distance > parent.detection_range + 20:
		_on_outside_range()
		parent.stop_move()
		transitioned.emit(self, "idle")
		parent.target = null
		return
	
	if distance <= parent.get_max_range():
		_on_inside_range()
		parent.stop_move()
		transitioned.emit(self, "attack")
		return
	else:
		_on_outside_attack_range()

func _on_outside_range() -> void:
	pass

func _on_inside_range() -> void:
	pass

func _on_outside_attack_range() -> void:
	parent.move(target_pos)
