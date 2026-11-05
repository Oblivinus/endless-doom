class_name HomingProjectile extends Projectile

@export_flags_3d_physics var homing_mask: int
@export var turning_speed: float = 6.0
@export var homing_radius: float = 17.5
@export var enable_following: bool = true

@export_group("Turning")
@export var turn_acceleration: bool = true
@export var max_turning_speed: float = 20.0
@export var turn_speed_accel: float = 10.0
var _accel_delta: float = 0.0

var homing_area: Area3D

var follow_target: Node3D
var stop_following_distance: float = 15

var _heading: Vector3 = Vector3.ZERO
var _target_queue: Array[Node3D] = []

func _ready() -> void:
	super()
	
	var shape = SphereShape3D.new()
	shape.radius = homing_radius
	homing_area = Util.create_area_3d(self, shape)
	homing_area.collision_mask = homing_mask
	
	homing_area.body_entered.connect(_queue_follow)

func _on_pool_spawn() -> void:
	_accel_delta = 0

func _on_pool_despawn() -> void:
	super()
	_target_queue.clear()
	stop_follow()

func _physics_process(delta: float) -> void:
	_process_follow(delta)

func _process_follow(delta: float) -> void:
	if not enable_following: return
	
	while not follow_target and _target_queue.size() > 0:
		var candidate = _target_queue.pop_front()
		if not is_instance_valid(candidate): continue
		follow_target = candidate
	
	if follow_target == null: return
	
	if not is_instance_valid(follow_target) or (follow_target is Humanoid and humanoid_stop_follow_condition(follow_target)):
		stop_follow(); return
	
	var desired_turn_speed: float = turning_speed
	if turn_acceleration:
		desired_turn_speed = move_toward(turning_speed, max_turning_speed, _accel_delta)
		_accel_delta = clampf(_accel_delta + turn_speed_accel * delta, 0.0, 10)
	
	var target_to: Vector3 = follow_target.global_position - global_position
	var distance: float = target_to.length()
	
	if distance < 0.1: stop_follow(); return
	if target_to.is_zero_approx(): return
	
	var target_dir = target_to.normalized()
	var t: float = clampf(desired_turn_speed * delta, 0, 1.0)
	
	_heading = _heading.lerp(target_dir, t)
	if _heading.is_zero_approx():
		_heading = target_dir
	_heading = _heading.normalized()
	
	linear_velocity = _heading * speed

func humanoid_stop_follow_condition(hum: Humanoid) -> bool:
	var finisher_state: bool = false
	
	if hum is Enemy:
		var enemy: Enemy = hum
		finisher_state = enemy.finisher_ready
		
	return hum.is_dead or finisher_state

func launch(direction: Vector3) -> void:
	super(direction)
	
	_heading = linear_velocity.normalized()

func stop_follow() -> void:
	follow_target = null
	_accel_delta = 0

func _queue_follow(target: Node3D) -> void:
	_target_queue.append(target)
