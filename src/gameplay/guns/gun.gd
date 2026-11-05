class_name Gun extends Node3D

@export var gun_shake: float = 0.2

@export_group("Stats")
@export var damage_range: Array[float] = [5, 3, 1.0]: get = get_damage_range ## [base, step, modifier]
@export var max_range: float = 25.0
@export var h_spread: float = 0.0
@export var v_spread: float = 45.0
@export var fire_rate: float = 2.0
@export var max_hit: int = 1
@export var type: Enums.GUN_TYPES = Enums.GUN_TYPES.BULLET
@export var damage_type: String = "normal"
@export var ammo_used: int = 1

@export_group("Dependecies")
@export var hitbox: Area3D
@export var anim_tree: AnimationTree
@export var sfx: String = "guns/pistol"

var collision_shape3d: CollisionShape3D
var timer: Timer
var parent: Arsenal
var playback: AnimationNodeStateMachinePlayback

var combat_info: CombatManager.CombatInfo
var _raycast: Raycast3d

var last_hit_count: int = 0
var damage: float: get = get_damage

func _ready() -> void:
	for child in hitbox.get_children():
		if child is CollisionShape3D:
			collision_shape3d = child
			break
	
	if not collision_shape3d:
		push_error("Collision Shape cannot be found")
		return
	else:
		collision_shape3d.shape = FrustumShape.new(Vector2(1, 4.5), h_spread, v_spread, max_range)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1/fire_rate
	add_child(timer)
	
	playback = anim_tree.get("parameters/playback")
	anim_tree.active = true

func _check_and_shoot() -> void:
	last_hit_count = 0
	
	var enemies = _check_for_valid_enemies()
	if enemies.is_empty(): return
	
	var check_count = 0
	for enemy: Enemy in enemies:
		var query = _check_ray_cast(enemy.global_position)
		if query.is_empty():
			hurt_enemy(enemy)
			parent.player.player_camera.shake(0.1)
		else:
			create_bullet_hit(query.position)
		
		last_hit_count += 1
		check_count += 1
		if check_count >= max_hit:
			break

func hurt_enemy(enemy: Enemy) -> void:
	enemy.hurt(damage, get_damage_info())

func get_damage_info() -> CombatManager.CombatInfo:
	if not combat_info:
		combat_info = CombatManager.CombatInfo.new(damage_type, parent.player)
	
	return combat_info

func get_damage_range() -> Array[float]:
	var range_copy: Array = damage_range.duplicate()
	if parent and parent.player:
		if range_copy.size() > 2:
			range_copy[2] = parent.player.damage_boost
		else:
			range_copy.append(parent.player.damage_boost)
	
	return range_copy

func get_damage() -> float:
	var range_copy: Array = damage_range.duplicate()
	var result: float = CombatManager.roll_damage_range(range_copy)
	
	return result

func _check_ray_cast(final_pos: Vector3) -> Dictionary:
	if _raycast == null:
		_raycast = Raycast3d.new(self)
		_raycast.mask([2])
	_raycast.from_to(global_position, final_pos)
	
	return _raycast.intersect()

func _check_for_valid_enemies() -> Array[Humanoid]:
	var result: Array[Humanoid] = []
	var bodies := hitbox.get_overlapping_bodies()
	if bodies.is_empty(): return result
	
	var origin := global_position
	
	var candidates: Array = []
	for b in bodies:
		if b is Humanoid and not b.is_dead:
			candidates.append([origin.distance_squared_to(b.global_position), b])
	
	if candidates.is_empty(): return result
	
	candidates.sort_custom(func(a, b): return a[0] < b[0])
	
	for c in candidates:
		var enemy: Humanoid = c[1]
		if _check_ray_cast(enemy.global_position).is_empty():
			result.append(enemy)
			if result.size() >= max_hit:
				break

	return result

func equip(new_owner: Arsenal):
	set_visibility(true, self)
	set_process(true)
	visible = true
	parent = new_owner

func unequip():
	set_visibility(false, self)
	set_process(false)
	visible = false
	parent = null

func ready_to_shoot() -> bool:
	return timer.time_left == 0 and parent and parent.is_ammo_enough(type, ammo_used)

func shoot() -> void:
	if not ready_to_shoot(): return
	timer.start()
	playback.travel("shoot")
	_check_and_shoot()
	consume_ammo()
	play_sfx()

func consume_ammo():
	parent.use_ammo(type, ammo_used)

func set_visibility(value: bool, node: Node = self) -> void:
	for child in node.get_children():
		if child is CanvasLayer: child.visible = value

func create_bullet_hit(pos: Vector3):
	var vfx = VfxConstructor.new("bullet_hit")

	var away_point: Vector3 = pos + (pos - global_position).normalized()
	var up: Vector3 = Vector3.UP
	if abs((pos - global_position).normalized().dot(up)) > 0.999:
		up = Vector3.FORWARD
	
	vfx.restart_at(pos)
	vfx.look_at(away_point, up)
	
func create_bullet_hit_ray(pos: Vector3):
	var query = _check_ray_cast(pos)
	if not query.is_empty():
		create_bullet_hit(query.position)

func play_sfx():
	GameManager.play_hearable_sound(sfx, self).play()

func farthest_center_vector() -> Vector3:
	return global_position + (global_basis * Vector3.FORWARD).normalized() * max_range
