class_name EnemyAttackState extends State

var on_cooldown := false
var ready_to_attack := false
var attacking := false
var is_disturbed := false
var strafing := false

func process_physics(_delta: float):
	if not parent.target: return
	if parent.is_hurted: is_disturbed = true
	var distance = parent.global_position.distance_to(parent.target.global_position)
	
	if distance > parent.detection_range:
		transitioned.emit(self, "idle")
		parent.target = null
		return
	
	if distance <= parent.attack_range:
		ready_to_attack = true
	elif not attacking:
		transitioned.emit(self, "chase")
		return
	
	if ready_to_attack and not on_cooldown:
		attacking = true
		on_cooldown = true
		parent.look_at(Globals.player.global_position)
		parent.on_attack.emit()
		get_tree().create_timer(0.7).timeout.connect(func():
			ready_to_attack = false
			attacking = false
			attack())
		
		await get_tree().create_timer(parent.attack_cd).timeout
		on_cooldown = false
		is_disturbed = false



func attack():
	if parent.is_dead or is_disturbed: return
	print("calculate Hitbox")
