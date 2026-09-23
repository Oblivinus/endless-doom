class_name ImpAttackState extends EnemyAttackState

func attack() -> void:
	await get_tree().create_timer(0.35).timeout
	var projectile = ProjectileLauncher.new("imp_orb", parent.global_position)
	projectile.launch(attack_pos)
	super()
