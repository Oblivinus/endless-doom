class_name Zombie extends Enemy

func _init() -> void:
	in_sight_sfx = ["possessed/possessed_sight 1", "possessed/possessed_sight 2", "possessed/possessed_sight 3"]
	dead_sfx = ["possessed/possessed_death 1", "possessed/possessed_death 2", "possessed/possessed_death 3"]
	idle_sfx = ["possessed/possessed_activity"]
	hurt_sfx = ["possessed/possessed_pain"]

func _on_hurt(dmg: float) -> void:
	super(dmg)
	var blood = VFX.new("blood_splatter")
	add_child(blood)
	blood.restart()
