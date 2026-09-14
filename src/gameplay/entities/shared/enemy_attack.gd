class_name EnemyAttackState extends State

var on_cooldown := false
var ready_to_attack := false

func process_physics(_delta: float):
	if not parent.target: return
	var distance = parent.global_position.distance_to(parent.target.global_position)
	
	if distance > parent.detection_range:
		transitioned.emit(self, "idle")
	
	if distance <= parent.attack_range:
		ready_to_attack = true
	else:
		ready_to_attack = false
		transitioned.emit(self, "chase")
	
	if ready_to_attack and not on_cooldown:
		parent.look_at(parent.target.global_position)
		parent.on_attack.emit()
		on_cooldown = true
		get_tree().create_timer(0.5).timeout.connect(func():
			if parent.died: return
			print("calculate Hitbox")
			)
		
		await get_tree().create_timer(parent.attack_cd).timeout
		on_cooldown = false



func attack():
	pass
