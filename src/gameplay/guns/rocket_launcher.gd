class_name RocketLauncher extends Gun

var cache_parent: Arsenal #NOTE: when switch gun the parent is null, this is the reason.

func  shoot() -> void:
	if not ready_to_shoot(): return
	cache_parent = parent
	parent.use_ammo(type)
	playback.travel("shoot")
	play_sfx()
	timer.start()
	
	var enemies = _check_for_valid_enemies()
	var origin = global_position + Vector3(0, -0.35, 0)
	var launcher: ProjectileLauncher = ProjectileLauncher.new("rocket", origin)
	var projectile: PlayerRocket = launcher.projectile as PlayerRocket
	projectile.projectile_owner = cache_parent.player
	projectile.max_damage = damage
	
	if enemies.is_empty():
		launcher.launch(farthest_center_vector())
	else:
		for enemy: Humanoid in enemies:
			launcher.launch(enemy.global_position)
			
	launcher.projectile.on_blast_hit.connect(_on_blast_hit)

func _on_blast_hit(targets: Array):
	for humanoid: Humanoid in targets:
		if humanoid is Player: continue
