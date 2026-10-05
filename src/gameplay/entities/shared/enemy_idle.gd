class_name EnemyIdleState extends State

const ABSOLUTE_DETECTED_RANGE: float = 2.5

var wander_timer: Timer
var anchor_pos: Vector3

func _state_machine_ready():
	parent.on_hurt_ex.connect(_on_hurt_ex)

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

func process_physics(_delta: float):
	if parent.target and not parent.target.is_dead:
		_on_detection()
		return
	
	wander()
	look_for()

func _on_hurt_ex(dmg_info: DamageInfo):
	if dmg_info and dmg_info.by is Player:
		parent.target = dmg_info.by

func _on_detection():
	parent.event.emit("in_sight")
	transitioned.emit(self, "attack")

func look_for():
	var player: Player = Globals.player
	
	var in_fov = check_in_pov(player.global_position)
	if not in_fov: return
	
	var in_sight = check_in_sight(player.global_position)
	if not in_sight: return
	
	parent.target = player

func wander():
	if wander_timer.time_left > 0 or parent.is_moving: return
	wander_timer.start()
	var rand_pos = Vector3(randi_range(-2, 2), 0, randi_range(-2, 2))
	
	if anchor_pos == Vector3.ZERO:
		anchor_pos = parent.global_position
	
	parent.move(anchor_pos + rand_pos)
			
	if randi_range(1, 5) == 1: parent.event.emit("random_idle")

func check_in_pov(target_pos: Vector3) -> bool:
	var distance = (Vector2(target_pos.x, target_pos.z) - Vector2(parent.global_position.x, parent.global_position.z)).length()
	var degree = parent.get_facing_degree_to(target_pos)
	
	if distance <= ABSOLUTE_DETECTED_RANGE:
		return true
	
	if degree < parent.fov and distance <= parent.detection_range:
		return true
	else:
		return false

func check_in_sight(target_pos: Vector3):
	var raycast = Raycast3d.new(parent)
	raycast.from_to(parent.global_position, target_pos)
	raycast.mask([2,4])
	var query = raycast.intersect()
	return query.is_empty()
