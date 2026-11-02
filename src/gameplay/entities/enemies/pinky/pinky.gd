class_name Pinky extends Enemy

func  _on_attack():
	Audio3D.new("pinky/pinky_attack", self).play()

func melee_attack_action() -> void:
	if is_dead or is_disturbed: return
	var humanoid: Humanoid = _check_for_target_in_melee()
	if humanoid:
		humanoid.hurt(melee_damage)
