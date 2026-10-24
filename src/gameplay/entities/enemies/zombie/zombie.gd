class_name Zombie extends Enemy

func _init() -> void:
	in_sight_sfx = ["possessed/possessed_sight 1", "possessed/possessed_sight 2", "possessed/possessed_sight 3"]
	dead_sfx = ["possessed/possessed_death 1", "possessed/possessed_death 2", "possessed/possessed_death 3"]
	idle_sfx = ["possessed/possessed_activity"]
	hurt_sfx = ["possessed/possessed_pain"]

func _ready() -> void:
	super()
	
	if attack_range > 0:
		range_attack_area = _create_range_area(FrustumShape.new(Vector2(0.5, 1), 0, 45, attack_range))
		add_child(range_attack_area)

func _on_missed_or_blocked(pos: Vector3 = Vector3.ZERO, _context: String = "none") -> void:
	if pos == Vector3.ZERO: return
	var vfx = VFX.new("bullet_hit", pos)
	Globals.world.add_child(vfx)
	vfx.global_basis = global_basis
	vfx.restart()

func attack_action() -> void:
	if is_dead: return
	$OmniLight3D.visible = true
	Audio3D.new("guns/pistol", self).play()
	var humanoid: Humanoid = _check_for_target()
	if humanoid:
		humanoid.hurt(attack_damage)
	await get_tree().create_timer(0.1).timeout
	$OmniLight3D.visible = false

func _on_hurt(dmg: float) -> void:
	super(dmg)
	var blood = VFX.new("blood_splatter", global_position)
	add_child(blood)
	blood.restart()
