@abstract class_name Item extends RigidBody3D

@export_flags_3d_physics var pick_up_mask: int = (1 << 0)
@export var pick_up_radius: float = 0.25

@export_category("Lifetime")
@export var expired: bool = false
@export var lifetime: float = 30

var pickable: bool = true
var collision_area: Area3D
var _lifetime_timer: Timer

#region FOLLOW VAR
var prev_mask: int
var follow_target: Node3D
var follow_speed: float = 10.0
var turning_speed: float = 3.5
var stop_following_distance: float = 15
var _heading: Vector3 = Vector3.ZERO

var max_speed: float = 20
var max_turn_speed: float = 10

var accel: float = 10
var accel_delta: float = 0.0
#endregion

static func _create_from_script(script: Script) -> Item:
	var path := script.resource_path.get_basename() + ".tscn"
	if ResourceLoader.exists(path):
		var packed: PackedScene = load(path)
		return packed.instantiate()
	else:
		print("scene doesn't exist for %s" % path)
		return null

static func create() -> Item:
	return _create_from_script(Item)

func _ready() -> void:
	collision_layer = (1 << 6) #layer 7
	prev_mask = collision_mask
	
	collision_area = Area3D.new()
	collision_area.collision_layer = 0
	collision_area.collision_mask = pick_up_mask
	add_child(collision_area)
	
	var pickup_collision_shape := CollisionShape3D.new()
	pickup_collision_shape.shape = SphereShape3D.new()
	pickup_collision_shape.shape.radius = pick_up_radius
	pickup_collision_shape.debug_color = Color.RED
	collision_area.add_child(pickup_collision_shape)
	collision_area.body_entered.connect(_on_pickup)
	
	var mat := PhysicsMaterial.new()
	mat.friction = 10.0
	mat.bounce = 0.0
	physics_material_override = mat
	linear_damp = 2.0
	lock_rotation = true
	
	if expired:
		_lifetime_timer = Timer.new()
		_lifetime_timer.one_shot = true
		_lifetime_timer.wait_time = lifetime
		_lifetime_timer.timeout.connect(queue_free)
		add_child(_lifetime_timer)
		_lifetime_timer.start()

func _physics_process(delta: float) -> void:
	_process_follow(delta)

func _process_follow(delta: float) -> void:
	if not follow_target: return
	if not pickable:
		set_obstacle(true)
		return
	else: set_obstacle(false)
	
	if not is_instance_valid(follow_target):
		stop_follow()
		return
	
	var target_to: Vector3 = follow_target.global_position - global_position
	if target_to.length() > stop_following_distance:
		stop_follow()
		return
	if target_to.is_zero_approx(): return
	var target_dir = target_to.normalized()
	
	var desired_speed = move_toward(follow_speed, max_speed, accel_delta)
	var desired_turn_speed = move_toward(turning_speed, max_turn_speed, accel_delta)
	accel_delta = clampf(accel_delta + accel * delta, 0.0, 10)
	
	var t: float = clampf(desired_turn_speed * delta, 0, 1.0)
	_heading = _heading.lerp(target_dir, t)
	if _heading.is_zero_approx():
		_heading = target_dir
	_heading = _heading.normalized()
	
	linear_velocity = _heading * desired_speed

func _on_pickup(other: Node3D) -> void:
	if not pickable: return
	var hum: Humanoid = other
	if hum is Humanoid: hum.on_pick_up.emit(self)
	
	queue_free()

func set_obstacle(value: bool):
	if value:
		gravity_scale = 2.0
		collision_mask = prev_mask
	else:
		gravity_scale = 0.0
		collision_mask = 0

func follow(node: Node3D) -> void:
	follow_target = node
	can_sleep = false
	sleeping = false
	accel_delta = 0.0
	
	if linear_velocity.length() > 0.1:
		_heading = linear_velocity.normalized()
	else:
		_heading = global_position.direction_to(node.global_position)

func stop_follow() -> void:
	follow_target = null
	can_sleep = true
	set_obstacle(true)
	linear_velocity = Vector3(linear_velocity.x, 0.0, linear_velocity.z) * 0.25
