class_name Cacodemon extends FlyingEnemy

func attack_action() -> void:
	var projectile = ProjectileLauncher.new("caco_fireball", global_position)
	projectile.projectile.damage = attack_damage
	projectile.launch(attack_pos)
