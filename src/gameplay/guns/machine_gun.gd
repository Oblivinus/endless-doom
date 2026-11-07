class_name MachineGun extends Gun

func shoot():
	if not ready_to_shoot(): return
	super()
	if last_hit_count < 1:
		create_bullet_hit_ray(farthest_center_vector())

func get_damage_info() -> CombatManager.CombatInfo:
	var dmg_info = super()
	dmg_info.pain_modifier = 0.45
	
	return dmg_info

func consume_ammo():
	var chance = randf()
	if chance <= 0.45:
		super()

func play_sfx():
	var vfx = GameManager.play_hearable_sound(sfx, self)
	vfx.pitch_scale = 1.5
	vfx.max_db = -7.5
	vfx.play()
