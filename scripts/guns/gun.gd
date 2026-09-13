@abstract
class_name Gun extends Node3D

@export_category("dependacies")
@export var animation: AnimatedSprite2D
@export var hit_box: Area3D
@export var camera: Camera3D
@export var gun_fire_sfx: AudioStreamPlayer3D
@export var omni_light: OmniLight3D

@export_category("stats")
@export var fire_rate: float = 2.0
@export var damage: float = 10.0

@export_category("resources")
@export var shot_sfx: AudioStream

var has_animation: bool = true
var last_shoot: float = 0.0

var can_shot: bool = true
var fire_cd: Timer


func _ready() -> void:
	fire_cd = Timer.new()
	fire_cd.one_shot = true
	fire_cd.timeout.connect(func(): can_shot = true)
	add_child(fire_cd)
	
	if animation != null:
		has_animation = true
		animation.animation_finished.connect(_on_animation_finish)
		animation.play("Idle")
		


func _process(delta: float) -> void:
	last_shoot += delta

func _on_animation_finish() -> void:
	if has_animation:
		animation.play("Idle")
		

func equip(new_camera: Camera3D):
	camera = new_camera

func _check_and_shoot() -> void:
	var enemies: Array[Node3D] = hit_box.get_overlapping_bodies()
	enemies.sort_custom(func(a: Node3D, b: Node3D): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	#print(enemies)
	for enemy: Enemy in enemies:
		var obstruction = _check_ray_cast_query(enemy.global_position)
		
		if obstruction.is_empty():
			enemy.hurt(damage)
		else:
			var vfx = VFX.new("blood_splatter", obstruction.position)
			Globals.world.add_child(vfx)
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
	if not can_shot:
		return
	can_shot = false
	fire_cd.start(1/fire_rate)
	
	omni_light.visible = true
	get_tree().create_timer(0.1).timeout.connect(func():
		omni_light.visible = false
		)
		
	Audio3dManagerGlobal.play_sound_at_position(shot_sfx, self).max_db = -2.0
	
	if has_animation:
		animation.play("Shoot")
	_check_and_shoot()
	last_shoot = 0.0
