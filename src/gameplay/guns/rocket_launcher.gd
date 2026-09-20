class_name RocketLauncher extends Gun

func  shoot() -> void:
	if not ready_to_shoot(): return
	playback.travel("shoot")
	timer.start()
	Audio3D.new("guns/rocket_launch", self).play()
	
	var enemies = _check_for_valid_enemies()
	var origin = global_position + Vector3(0, -0.35, 0)
	if enemies.is_empty():
		var launcher: ProjectileLauncher = ProjectileLauncher.new("rocket", origin)
		launcher.launch(farthest_center_vector())
	else:
		for enemy: Humanoid in enemies:
			var launcher: ProjectileLauncher = ProjectileLauncher.new("rocket", origin)
			launcher.launch(enemy.global_position + Vector3(0, -0.75, 0))
