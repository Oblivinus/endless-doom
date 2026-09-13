class_name EnemyAttackState extends State

var on_cooldown := false
var ready_to_attack := false

func process_physics(_delta: float):
	if not parent.target: return
	var distance = parent.global_position.distance_to(parent.target.global_position)
	
	parent.look_at(parent.target.global_position)
	
	if distance > parent.detection_range:
		transitioned.emit(self, "idle")
	
	if distance <= parent.attack_range:
		ready_to_attack = true
		pass
	else:
		transitioned.emit(self, "chase")
		pass
	
	if ready_to_attack and not on_cooldown:
		on_cooldown = true
		await get_tree().create_timer(0.25).timeout
