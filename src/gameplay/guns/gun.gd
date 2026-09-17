class_name NewGun extends Node3D

@export_category("Stats")
@export var damage: float = 10.0
@export var max_range: float = 25.0
@export var h_spread: float = 0.0
@export var v_spread: float = 45.0
@export var fire_rate: float = 2.0
@export var max_hit: int = 1

@export_category("Dependecies")
@export var hitbox: Area3D
@export var anim_tree: AnimationTree

var collision_shape3d: CollisionShape3D
var timer: Timer
var parent: Humanoid
var playback: AnimationNodeStateMachinePlayback

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
	var enemies = hitbox.get_overlapping_bodies()
	enemies.sort_custom(func(a: Node3D, b: Node3D): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	if enemies.is_empty():
		var query = _check_ray_cast(farthest_center_vector())
		if query.is_empty(): return
		create_bullet_hit(query.position)
		return
	
	var check_count = 0
	for enemy: Humanoid in enemies:
		var query = _check_ray_cast(enemy.global_position)
		if query.is_empty():
			enemy.hurt(damage)
		else:
			create_bullet_hit(query.position)
		
		check_count += 1
		if check_count >= max_hit:
			break

func _check_ray_cast(final_pos: Vector3) -> Dictionary:
	var raycast = Raycast3d.new(self)
	raycast.from_to(global_position, final_pos)
	raycast.mask([2,4])
	var query = raycast.interect()
	
	return query

func equip(new_owner: Humanoid):
	parent = new_owner

func unequip():
	parent = null

func shoot():
	if timer.time_left > 0 or not parent: return
	Audio3D.new("pistol_shot", self).play()
	timer.start()
	playback.travel("shoot")
	_check_and_shoot()
	pass

func create_bullet_hit(pos: Vector3):
	var vfx = VFX.new("bullet_hit", pos)
	Globals.world.add_child(vfx)
	vfx.global_basis = global_basis
	vfx.restart()

func farthest_center_vector():
	return global_position + (global_basis * Vector3.FORWARD).normalized() * max_range
