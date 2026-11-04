class_name HellKnight extends Enemy

@export var melee_attack_cd: float = 0.15

func _physics_process(delta: float) -> void:
	super(delta)
	
	if not target: return
	if global_position.distance_squared_to(target.global_position) > pow(melee_range, 2): return
	if is_on_cooldown() and attack_timer.wait_time != melee_attack_cd:
		attack_timer.stop()
		attack_timer.timeout.emit()

func attack_action() -> void:
	attack_timer.wait_time = attack_cd
	
	var launcher: ProjectileLauncher = ProjectileLauncher.new("hell_knight_projectile", global_position)
	var projectile: HellKnightProjectile = launcher.projectile as HellKnightProjectile
	projectile.damage = attack_damage
	launcher.launch(attack_pos)

func melee_attack_action() -> void:
	attack_timer.wait_time = melee_attack_cd
	
	var humanoid: Humanoid = _check_for_target_in_melee()
	if humanoid:
		humanoid.hurt(melee_damage)
