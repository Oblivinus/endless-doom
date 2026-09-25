class_name RocketLauncher extends Gun

func  shoot() -> void:
	if not ready_to_shoot(): return
	parent.use_ammo(type)
	playback.travel("shoot")
	timer.start()
	Audio3D.new("guns/rocket_launch", self).play()
	
	var enemies = _check_for_valid_enemies()
	var origin = global_position + Vector3(0, -0.35, 0)
	var launcher: ProjectileLauncher = ProjectileLauncher.new("rocket", origin)
	
	if enemies.is_empty():
		launcher.launch(farthest_center_vector())
	else:
		for enemy: Humanoid in enemies:
			launcher.launch(enemy.global_position + Vector3(0, -0.75, 0))
			
	launcher.projectile.on_blast_hit.connect(_on_blast_hit)

func _on_blast_hit(targets: Array):
	for humanoid: Humanoid in targets:
		if humanoid is Player: continue
		if humanoid is Humanoid and humanoid.is_dead: parent.register_kill(humanoid)
