class_name Pistol extends Gun


func shoot():
	if not ready_to_shoot(): return
	super()
	if last_hit_count < 1:
		create_bullet_hit_ray(farthest_center_vector())
