class_name Imp extends Enemy

func attack_action() -> void:
	var projectile = ProjectileLauncher.new("imp_orb", global_position)
	projectile.projectile.damage = attack_damage
	projectile.launch(attack_pos)

func melee_attack_action() -> void:
	if is_dead or is_disturbed: return
	var humanoid: Humanoid = _check_for_target_in_melee()
	if humanoid:
		humanoid.hurt(melee_damage)

func _on_hurt(dmg: float) -> void:
	super(dmg)
	var blood = VFX.new("blood_splatter", global_position)
	add_child(blood)
	blood.restart()
