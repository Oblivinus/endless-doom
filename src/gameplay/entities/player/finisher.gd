class_name Finisher extends Node3D

@export var arsenal: Arsenal

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer

var reached: bool = false
var finishing: bool = false
var target_pos: Vector3
var enemy: Enemy

var hitbox: Area3D

func _ready() -> void:
	hitbox = Area3D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = (1 << 2)
	add_child(hitbox)
	
	var collision_shape3d: CollisionShape3D = CollisionShape3D.new()
	collision_shape3d.shape = FrustumShape.new(Vector2(2, 3), 15, 45, 12)
	hitbox.add_child(collision_shape3d)
	
	sprite.visible = false

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"): return
	finish_it()

func _process(delta: float) -> void:
	if not finishing or target_pos == Vector3.ZERO: return
	var player_pos := arsenal.player.global_position
	
	arsenal.player.global_position = lerp(player_pos, target_pos, delta * 30.0)
	arsenal.player.look_at_pos(enemy.global_position)
	
	if arsenal.player.global_position.distance_to(target_pos) <= 0.1:
		_move_to_reached()

func _check_for_finisher() -> void:
	var enemies = hitbox.get_overlapping_bodies()
	enemies = enemies.filter(func(body): return body.is_in_group("finisher_ready"))
	enemies.sort_custom(func(a: Node3D, b: Node3D): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	if enemies.is_empty(): return
	finishing = true
	
	var enemy: Enemy = enemies[0]
	var query = _check_ray_cast(enemy.global_position)
	
	if not query.is_empty(): 
		finishing = false
		return
	_move_to_enemy(enemy)

func _check_ray_cast(final_pos: Vector3) -> Dictionary:
	var raycast = Raycast3d.new(self)
	raycast.from_to(global_position, final_pos)
	raycast.mask([2, 5])
	var query = raycast.intersect()
	
	return query

func _move_to_enemy(target_enemy: Enemy) -> void:
	enemy = target_enemy
	target_pos = enemy.global_position + (arsenal.player.global_basis.z * 2)
	
	_set_player_for_finisher(true)

func _set_player_for_finisher(value: bool) -> void:
	arsenal.player.disable_movement(value)
	arsenal.player.camera_disable = value
	arsenal.player.invincible = value

func _move_to_reached() -> void:
	var combat_info = CombatManager.CombatInfo.new("forceful", arsenal.player)
	play_anim()
	enemy.hurt(9999, combat_info)
	reached = true
	
	Engine.time_scale = 0.35
	await get_tree().create_timer(0.35).timeout
	Engine.time_scale = 1.0
	_set_player_for_finisher(false)
	
	reached = false
	target_pos = Vector3.ZERO
	enemy = null
	finishing = false
	stop_anim()

func play_anim() -> void:
	sprite.visible = true
	anim.play("finisher_anim")

func stop_anim() -> void:
	sprite.visible = false
	anim.stop()

func finish_it() -> void:
	if finishing: return
	_check_for_finisher()
