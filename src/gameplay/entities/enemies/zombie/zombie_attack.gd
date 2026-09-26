class_name ZombieAttackState extends EnemyAttackState

func on_missed_or_blocked(block_pos: Vector3 = Vector3.ZERO):
	if block_pos != Vector3.ZERO:
		var vfx = VFX.new("bullet_hit", block_pos)
		Globals.world.add_child(vfx)
		vfx.global_basis = parent.global_basis
		vfx.restart()

func attack():
	if parent.is_dead or is_disturbed: return
	$"../../OmniLight3D".visible = true
	Audio3D.new("guns/pistol", parent).play()
	var humanoid: Humanoid = _check_for_target()
	if humanoid:
		humanoid.hurt(parent.attack_damage)
	await get_tree().create_timer(0.1).timeout
	$"../../OmniLight3D".visible = false
