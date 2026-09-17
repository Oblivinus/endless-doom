@abstract
class_name Gun extends Node3D

@export_category("dependacies")
@export var anim_tree: AnimationTree
@export var hit_box: Area3D
@export var far_center: Marker3D

@export_category("stats")
@export var fire_rate: float = 2.0
@export var damage: float = 10.0
@export var max_enemy_hit: int = 1
@export var auto: bool = false

@export_category("resources")
@export var shot_sfx: AudioStream

var has_animation: bool = true
var last_shoot: float = 0.0

var can_shot: bool = true
var fire_cd: Timer
var parent: Humanoid
var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	playback = anim_tree.get("parameters/playback")
	anim_tree.active = true
	fire_cd = Timer.new()
	fire_cd.one_shot = true
	fire_cd.timeout.connect(func(): can_shot = true)
	add_child(fire_cd)
		


func _process(delta: float) -> void:
	last_shoot += delta

func _on_animation_finish() -> void:
	pass

func equip(new_parent: Humanoid):
	parent = new_parent

func unequip():
	parent = null

func _check_and_shoot() -> void:
	var enemies: Array[Node3D] = hit_box.get_overlapping_bodies()
	enemies.sort_custom(func(a: Node3D, b: Node3D): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	
	if enemies.is_empty():
		var obstruction = _check_ray_cast_query(far_center.global_position)
		if obstruction.is_empty(): return
		var vfx = VFX.new("bullet_hit", obstruction.position)
		Globals.world.add_child(vfx)
		vfx.global_basis = global_basis
		vfx.restart()
		return
	
	for enemy: Enemy in enemies:
		var obstruction = _check_ray_cast_query(enemy.global_position)
		
		if obstruction.is_empty():
			enemy.hurt(damage)
		else:
			var vfx = VFX.new("bullet_hit", obstruction.position)
			Globals.world.add_child(vfx)
			vfx.global_basis = global_basis
			vfx.restart()
		break



func _check_ray_cast_query(final_pos: Vector3) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	
	var origin = global_position
	var end = final_pos
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = (1 << 1)
	
	var result = space_state.intersect_ray(query)
	
	return result



func _get_enemy_ancestor(node: Node) -> Enemy:
	var current_parent: Node = node
	
	while current_parent != null:
		if current_parent is Enemy:
			if current_parent.died:
				return null
				
			return current_parent
		current_parent = current_parent.get_parent()
	return null

func shoot():
	if not can_shot or not parent:
		return
	can_shot = false
	playback.travel("shoot")
	fire_cd.start(1/fire_rate)
	
	Audio3dManager.play_sound_at_position(shot_sfx, self).max_db = -2.0
	_check_and_shoot()
	last_shoot = 0.0
