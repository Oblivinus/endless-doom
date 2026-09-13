class_name EnemyIdleState extends State

@export var test_cube: CSGBox3D

@export_category("detection")
@export var FOV: int = 45
@export var idle_status: Enums.IDLE_STATUS = Enums.IDLE_STATUS.WANDERING

var anchor_pos: Vector3
var wander_random_timer: float = 0.0

func _ready() -> void:
	test_cube.material_override = StandardMaterial3D.new()
	test_cube.material_override.albedo_color = Color.WHITE



func _check_ray_cast_query() -> Dictionary:
	var space_state = parent.get_world_3d().direct_space_state
	var origin = parent.global_position
	var end_pos = Globals.player.global_position
	
	var query = PhysicsRayQueryParameters3D.create(origin, end_pos)
	query.exclude = [parent, Globals.player]
	query.collision_mask = (1 << 1) | (1 << 3)
	
	var result = space_state.intersect_ray(query)
	return result



func enter() -> void:
	anchor_pos = parent.global_position
	#print(parent)



func process_physics(delta: float):
	var is_in_range = check_in_detection_range()
	
	if idle_status == Enums.IDLE_STATUS.WANDERING and not parent.is_moving:
		wander_random_timer += delta
		if wander_random_timer >= 2:
			wander_random_timer = 0
			var rand_pos = Vector3(randi_range(-2, 2), 0, randi_range(-2, 2))
			parent.move_to(anchor_pos + rand_pos)
		
	if is_in_range:
		parent.target = Globals.player
		transitioned.emit(self, "attack")
		pass

func check_in_detection_range() -> bool:
	var distance = (parent.global_position - Globals.player.global_position).length()
	var is_in_range_valid: bool = false
	
	
	if distance <= parent.detection_range:
		#NOTE: if empty that mean there nothing blocking it vision
		is_in_range_valid = _check_ray_cast_query().is_empty()
	else:
		parent.target = null
		return false
	
	if is_in_range_valid:
		parent.target = Globals.player
		return true
	else :
		#print("In range and but not valid")
		return false



func check_in_pov(target_pos: Vector3) -> bool:
	var distance = (Vector2(target_pos.x, target_pos.z) - Vector2(parent.global_position.x, parent.global_position.z)).length()
	var degree = parent.get_facing_degree_to(target_pos)
	
	if degree <= FOV and distance <= parent.attack_range * 1.5:
		#print("in ", parent.name, "'s FOV")
		test_cube.material_override.albedo_color = Color.RED
		return true
	else:
		test_cube.material_override.albedo_color = Color.WHITE
		return false



func change_idle_status(status: Enums.IDLE_STATUS):
	idle_status = status
