class_name ImpAttackState extends EnemyAttackState

func attack() -> void:
	await get_tree().create_timer(0.35).timeout
	var projectile = ProjectileLauncher.new("imp_orb", parent.global_position)
	projectile.launch(attack_pos)
	
func melee_attack() -> void:
	if parent.is_dead or is_disturbed: return
	var humanoid: Humanoid = _check_for_target_in_melee()
	if humanoid:
		humanoid.hurt(parent.melee_damage)
