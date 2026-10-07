class_name MachineGun extends Gun

func shoot():
	if not ready_to_shoot(): return
	super()
	var vfx = Audio3D.new("guns/pistol", self)
	vfx.pitch_scale = randf_range(0.8, 1.2)
	vfx.play()
	if last_hit_count < 1:
		create_bullet_hit_ray(farthest_center_vector())

func get_damage_info() -> DamageInfo:
	var dmg_info = super()
	dmg_info.pain_modifier = 0.45
	
	return dmg_info

func consume_ammo():
	var chance = randf()
	if chance <= 0.45:
		parent.use_ammo(type)

func play_sfx():
	var vfx = GameManager.play_hearable_sound(sfx, self)
	vfx.pitch_scale = randf_range(0.8, 1.2)
	vfx.play()
