class_name Zombie extends Enemy

func hurt(dmg: float) -> void:
	super(dmg)
	var blood = VFX.new("blood_splatter")
	add_child(blood)
	blood.restart()
	if not is_dead:
		Audio3D.new("zombie_pain", self).play()
