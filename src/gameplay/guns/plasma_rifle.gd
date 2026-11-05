class_name PlasmaRifle extends Gun

@export var shot_before_cooldown: int = 20
var shotted: int = 0
var last_shot: float = 0

var cache_parent: Arsenal #NOTE: when switch gun the parent is null, this is the reason.
var connection: Signal

func consume_ammo():
	var chance = randf()
	if chance <= 0.33:
		super()

func play_sfx():
	var vfx = GameManager.play_hearable_sound(sfx, self)
	vfx.pitch_scale = randf_range(1, 1.1)
	vfx.max_db = -1
	vfx.play()

func play_shoot_anim() -> void:
	var chance = randf()
		
	if chance <= 0.55:
		playback.start("shoot")
	else:
		playback.start("shoot2")

func unequip():
	super()
	shotted = 0

func  shoot() -> void:
	if not ready_to_shoot(): return
	cache_parent = parent
	
	consume_ammo()
	play_shoot_anim()
	play_sfx()
	
	var enemies = _check_for_valid_enemies()
	var origin = global_position + Vector3(0, -0.35, 0) + (-global_basis.z)
	var launcher: ProjectileLauncher = ProjectileLauncher.new("plasma_bolt", origin)
	var projectile: PlasmaBolt = launcher.projectile as PlasmaBolt
	
	if enemies.is_empty():
		launcher.launch(farthest_center_vector())
	else:
		for enemy: Humanoid in enemies:
			launcher.launch(enemy.global_position)
	
	projectile.on_hit.connect(_on_hit)
	
	var elapsed_msec = Time.get_ticks_msec() - last_shot
	if elapsed_msec/1000 >= 1:
		shotted = 0
	
	shotted += 1
	
	if shotted >= shot_before_cooldown:
		#print("oveheat: %d" % shotted)
		timer.wait_time = 1.5
		playback.travel("overheat")
		shotted = 0
	else:
		timer.wait_time = 1 / fire_rate
	
	last_shot = Time.get_ticks_msec()
	timer.start()

func _on_hit(target: Node3D):
	if not target is Humanoid: return
	target.hurt(damage, get_damage_info())
	if target.is_dead: cache_parent.register_kill(target)
