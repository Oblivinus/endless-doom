class_name FlyingEnemy extends Enemy

#region FLYING
var hover_offset: float = 4
var hover_smoothing: float = 5.0

var change_timer: float = 0.0
var hover_height_change_time: float = 5.0

# Bob
var bob_amplitude: float = 0.35
var bob_speed: float = 5.0
var _bob_time: float = randf() * TAU

# Obstacle avoidance
var climb_offset: float = 0.0
var max_climb: float = 6.0
var climb_speed: float = 4.0
var look_ahead: float = 2.5   

#endregion

func get_enemy_floor_Y_offset() -> float:
	var shape = $CollisionShape3D.shape
	if shape is SphereShape3D:
		return shape.radius - 0.1
	return super()

func _ready() -> void:
	super()
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

func _process_gravity(delta):
	if is_dead: super(delta)

func _process_moving(delta: float) -> void:
	super(delta)
	if is_dead: return
	
	_bob_time += delta * bob_speed
	var bob := sin(_bob_time) * bob_amplitude
	var desired_y := hover_offset + climb_offset + bob
	
	_update_climb(delta)
	
	velocity.y = (desired_y - global_position.y) * hover_smoothing

func _update_climb(delta: float) -> void:
	# move_dir is Vector3.ZERO when not moving, so the enemy settles back down when idle
	if move_dir == Vector3.ZERO:
		climb_offset = move_toward(climb_offset, 0.0, climb_speed * delta)
		return
	
	if _is_blocked_at_height(global_position.y):
		# Something is in front of us right now: go up
		climb_offset = min(climb_offset + climb_speed * delta, max_climb)
	elif climb_offset > 0.0 and not _is_blocked_at_height(hover_offset):
		# Clear at the original hover height too: safe to come back down
		climb_offset = max(climb_offset - climb_speed * delta, 0.0)
	# else: clear at the current height but still blocked at the original one -> hold

func _is_blocked_at_height(y: float) -> bool:
	var from := Vector3(global_position.x, y, global_position.z)
	var to := from + move_dir * look_ahead
	var raycast = Raycast3d.new(self)
	raycast.from_to(from, to)
	raycast.mask([2, 4])
	return not raycast.intersect().is_empty()

func knockback(force: Vector3) -> void:
	force.y = 0
	super(force)

func move(target_pos: Vector3):
	pathfind.stop()
	move_to(target_pos)

func navigate_to(target_pos: Vector3) -> void:
	move(target_pos)
