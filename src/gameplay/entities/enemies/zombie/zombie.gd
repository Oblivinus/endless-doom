class_name Zombie extends Enemy

func hurt(dmg: float) -> void:
	super(dmg)
	var blood = VFX.new("blood_splatter")
	add_child(blood)
	blood.restart()
	if not is_dead:
		Audio3dManager.play_sound_at_position(sounds["hurt"], self).volume_db = -10
