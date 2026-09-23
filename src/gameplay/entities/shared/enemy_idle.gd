class_name EnemyIdleState extends State

@export_category("detection")
@export var FOV: int = 45
@export var idle_status: Enums.IDLE_STATUS = Enums.IDLE_STATUS.WANDERING

var wander_timer: Timer
var anchor_pos: Vector3

func _ready() -> void:
	wander_timer = Timer.new()
	wander_timer.one_shot = true
	wander_timer.wait_time = 2
	add_child(wander_timer)



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

func process_physics(delta: float):
	var is_in_range = check_in_detection_range()
	wander()
	
	if not is_in_range: return
	_on_detection()

func _on_detection():
	parent.event.emit("in_sight")
	transitioned.emit(self, "attack")

func check_in_detection_range() -> bool:
	if Globals.player.is_dead:
		parent.target = null
		return false
	
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
		return false

func wander():
	if wander_timer.time_left > 0 or parent.is_moving: return
	wander_timer.start()
	var rand_pos = Vector3(randi_range(-2, 2), 0, randi_range(-2, 2))
	parent.move_to(anchor_pos + rand_pos)
			
	if randi_range(1, 5) == 1: parent.event.emit("random_idle")

func check_in_pov(target_pos: Vector3) -> bool:
	var distance = (Vector2(target_pos.x, target_pos.z) - Vector2(parent.global_position.x, parent.global_position.z)).length()
	var degree = parent.get_facing_degree_to(target_pos)
	
	if degree <= FOV and distance <= parent.attack_range * 1.5:
		return true
	else:
		return false
