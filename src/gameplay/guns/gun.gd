class_name Gun extends Node3D

@export_category("Stats")
@export var damage: float = 10.0
@export var max_range: float = 25.0
@export var h_spread: float = 0.0
@export var v_spread: float = 45.0
@export var fire_rate: float = 2.0
@export var max_hit: int = 1
@export var type: Enums.GUN_TYPES = Enums.GUN_TYPES.BULLET
@export var damage_type: String = "normal"

@export_category("Dependecies")
@export var hitbox: Area3D
@export var anim_tree: AnimationTree

var collision_shape3d: CollisionShape3D
var timer: Timer
var parent: Arsenal
var playback: AnimationNodeStateMachinePlayback

var last_hit_count: int = 0

func _ready() -> void:
	for child in hitbox.get_children():
		if child is CollisionShape3D:
			collision_shape3d = child
			break
	
	if not collision_shape3d:
		push_error("Collision Shape cannot be found")
		return
	else:
		collision_shape3d.shape = FrustumShape.new(Vector2(2, 3), h_spread, v_spread, max_range)
	
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1/fire_rate
	add_child(timer)
	
	playback = anim_tree.get("parameters/playback")
	anim_tree.active = true

func _check_and_shoot() -> void:
	last_hit_count = 0
	
	var enemies = hitbox.get_overlapping_bodies()
	enemies.sort_custom(func(a: Node3D, b: Node3D): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	if enemies.is_empty(): return
	
	var check_count = 0
	for enemy: Enemy in enemies:
		var query = _check_ray_cast(enemy.global_position)
		if query.is_empty():
			hurt_enemy(enemy)
			if enemy.is_dead: parent.register_kill(enemy)
		else:
			create_bullet_hit(query.position)
		
		last_hit_count += 1
		check_count += 1
		if check_count >= max_hit:
			break

func hurt_enemy(enemy: Enemy) -> void:
	enemy.hurt(damage, get_damage_info())

func get_damage_info() -> DamageInfo:
	return DamageInfo.new(damage_type, parent.player)

func _check_ray_cast(final_pos: Vector3) -> Dictionary:
	var raycast = Raycast3d.new(self)
	raycast.from_to(global_position, final_pos)
	raycast.mask([2])
	var query = raycast.intersect()
	
	return query

func _check_for_valid_enemies() -> Array[Humanoid]:
	var result: Array[Humanoid] = []
	var enemies = hitbox.get_overlapping_bodies()
	enemies.sort_custom(func(a: Node3D, b: Node3D): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	if enemies.is_empty(): return result
	
	var check_count = 0
	for enemy: Humanoid in enemies:
		var query = _check_ray_cast(enemy.global_position)
		if query.is_empty():
			result.append(enemy)
		
		check_count += 1
		if check_count >= max_hit:
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
	return timer.time_left == 0 and parent and parent.get_ammos(type) > 0

func shoot() -> void:
	if not ready_to_shoot(): return
	timer.start()
	playback.travel("shoot")
	_check_and_shoot()
	consume_ammo()
	Globals.trigger_sound_detection(global_position)

func consume_ammo():
	parent.use_ammo(type)

func set_visibility(value: bool, node: Node = self) -> void:
	for child in node.get_children():
		if child is CanvasLayer: child.visible = value

func create_bullet_hit(pos: Vector3):
	var vfx = VFX.new("bullet_hit", pos)
	Globals.world.add_child(vfx)
	vfx.global_position = pos

	var away_point: Vector3 = pos + (pos - global_position).normalized()
	var up: Vector3 = Vector3.UP
	if abs((pos - global_position).normalized().dot(up)) > 0.999:
		up = Vector3.FORWARD

	vfx.look_at(away_point, up)
	vfx.restart()
	
func create_bullet_hit_ray(pos: Vector3):
	var query = _check_ray_cast(pos)
	if not query.is_empty():
		create_bullet_hit(query.position)

func farthest_center_vector() -> Vector3:
	return global_position + (global_basis * Vector3.FORWARD).normalized() * max_range
