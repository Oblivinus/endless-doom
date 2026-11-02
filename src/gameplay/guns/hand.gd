class_name Hand extends Gun

var hit_count: int = 1
var speed_multiplier: float = 1.5

func _ready() -> void:
	super()
	collision_shape3d.shape = FrustumShape.new(Vector2(4, 3), h_spread, v_spread, max_range)

func ready_to_shoot() -> bool:
	return timer.time_left == 0 and parent

func shoot() -> void:
	if not ready_to_shoot(): return
	timer.start()
	if hit_count == 1:
		playback.travel("shoot")
		hit_count = 2
	else:
		playback.travel("shoot2")
		hit_count = 1
	_check_and_shoot()
	
	play_sfx()
	if last_hit_count < 1:
		create_bullet_hit_ray(farthest_center_vector())


func equip(new_owner: Arsenal):
	super(new_owner)
	parent.player.move_speed *= speed_multiplier

func unequip():
	if parent: parent.player.move_speed /= speed_multiplier
	super()

func get_damage_info() -> CombatManager.CombatInfo:
	var sup = super()
	sup.pain_modifier = 2.0
	sup.type = "forceful"
	return sup

func hurt_enemy(enemy: Enemy) -> void:
	var knock_force = global_position.direction_to(enemy.global_position) * 2.5
	
	enemy.hurt(damage, get_damage_info())
	
	if enemy.is_dead:
		knock_force *= 10
		var vfx = VfxConstructor.new("explosion")
		vfx.restart_at(enemy.global_position + Vector3(0, -0.5, 0))
	
		var audio = GameManager.play_hearable_sound("gameplay/explode",  vfx)
		audio.max_db = 10
		audio.play()
	
	enemy.knockback(knock_force)

func play_sfx():
	var vfx = Audio3D.new(sfx, self)
	vfx.pitch_scale = randf_range(0.95, 1.05)
	vfx.play()
