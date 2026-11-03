class_name Finisher extends Node3D

const FINISH_DAMAGE: float = 9999.0
const MOVE_LERP_SPEED: float = 30.0
const REACH_DISTANCE: float = 0.1
const STAND_OFFSET: float = 1.2
const SLOW_TIME_SCALE: float = 1.0
const SLOW_DURATION: float = 0.35
const RAY_MASK: Array[int] = [2, 5]
const INVICIBILITY_GRACE: float = 1.0

const APPROACH_SPEED: float = 60.0
const MAX_APPROACH_TIME: float = 0.4

var stand_dir: Vector3

@export var arsenal: Arsenal
@export var finisher_delay: float = 0.05

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer

var delay_timer: Timer
var reached: bool = false
var finishing: bool = false
var target_pos: Vector3
var enemy: Enemy
var time_took: float = 0.0

var hitbox: Area3D

func _ready() -> void:
	_create_hitbox()
	_create_delay_timer()
	sprite.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		finish_it()

func _physics_process(delta: float) -> void:
	if not finishing: 
		time_took = 0.0
		return
	if not is_instance_valid(enemy):
		_reset()
		return
	
	var player := arsenal.player
	_update_target_pos()
	player.look_at_pos(enemy.global_position)
	if reached: return
	
	player.global_position = player.global_position.move_toward(target_pos, APPROACH_SPEED * delta)
	time_took += delta
	
	if player.global_position.distance_to(target_pos) <= REACH_DISTANCE \
			or time_took >= MAX_APPROACH_TIME:
		_move_to_reached()

#region SETUP
func _create_hitbox() -> void:
	hitbox = Area3D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 0
	hitbox.set_collision_mask_value(8, true)
	add_child(hitbox)
	
	var collision_shape3d := CollisionShape3D.new()
	collision_shape3d.shape = FrustumShape.new(Vector2(2, 4.5), 15, 45, 12)
	hitbox.add_child(collision_shape3d)

func _create_delay_timer() -> void:
	delay_timer = Timer.new()
	delay_timer.one_shot = true
	delay_timer.wait_time = finisher_delay
	add_child(delay_timer)
#endregion

#region FINISHER LOGIC
func finish_it() -> void:
	if finishing or delay_timer.time_left > 0: return
	_check_for_finisher()

func _check_for_finisher() -> void:
	var enemies := hitbox.get_overlapping_bodies()
	if enemies.is_empty(): return
	
	enemies.sort_custom(
		func(a: Node3D, b: Node3D):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	var nearest: Enemy = enemies[0]
	if not _check_ray_cast(nearest.global_position).is_empty(): return
	
	finishing = true
	_move_to_enemy(nearest)

func _check_ray_cast(final_pos: Vector3) -> Dictionary:
	var raycast = Raycast3d.new(self)
	raycast.from_to(global_position, final_pos)
	raycast.mask(RAY_MASK)
	return raycast.intersect()

func _move_to_enemy(target_enemy: Enemy) -> void:
	enemy = target_enemy
	var player := arsenal.player
	# horizontal direction from enemy toward the player, fixed at start
	stand_dir = player.global_position - enemy.global_position
	stand_dir.y = 0
	stand_dir = stand_dir.normalized() if not stand_dir.is_zero_approx() else player.global_basis.z
	_update_target_pos()
	time_took = 0.0
	_set_player_for_finisher(true)

func _move_to_reached() -> void:
	reached = true
	play_anim()
	
	var combat_info = CombatManager.CombatInfo.new("forceful", arsenal.player)
	combat_info.finisher = true
	enemy.hurt(enemy.max_health, combat_info, true)
	arsenal.player.health += 8
	CombatManager._on_finisher(enemy)
	
	Audio3D.new("guns/projectile_contact", arsenal).play()
	
	arsenal.player.player_camera.shake(0.5)
	arsenal.finisher_signal.emit(enemy)
	
	if arsenal.player.global_position.distance_to(target_pos) < 1.0:
		arsenal.player.global_position = target_pos
	
	arsenal.player.knockback(arsenal.player.global_basis.z * 10)
	
	Engine.time_scale = SLOW_TIME_SCALE
	await get_tree().create_timer(SLOW_DURATION).timeout
	Engine.time_scale = 1.0
	_reset()
	delay_timer.start(finisher_delay)

func _update_target_pos() -> void:
	target_pos = enemy.global_position + stand_dir * STAND_OFFSET
	#var player := arsenal.player
	#target_pos.y = player.global_position.y   # or clamp to a sane range for flyers

func _reset() -> void:
	_set_player_for_finisher(false)
	reached = false
	target_pos = Vector3.ZERO
	enemy = null
	finishing = false
	stop_anim()

func _set_player_for_finisher(value: bool) -> void:
	var player := arsenal.player
	player.disable_movement(value)
	player.camera_disable = value
	
	if value:
		player.invincible = true
	else:
		_end_invincibility()

func _end_invincibility() -> void:
	await get_tree().create_timer(INVICIBILITY_GRACE).timeout
	if not finishing:
		arsenal.player.invincible = false
#endregion

#region ANIMATION
func play_anim() -> void:
	sprite.visible = true
	anim.play("finisher_anim")

func stop_anim() -> void:
	sprite.visible = false
	anim.stop()
#endregion
