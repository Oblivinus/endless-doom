class_name Imp extends Enemy

func _init() -> void:
	in_sight_sfx = ["imp/imp_sight 1", "imp/imp_sight 2"]
	dead_sfx = ["imp/imp_death 1", "imp/imp_death 2"]
	idle_sfx = ["imp/imp_activity"]
	hurt_sfx = []

func _on_hurt(dmg: float) -> void:
	super(dmg)
	var blood = VFX.new("blood_splatter")
	add_child(blood)
	blood.restart()
