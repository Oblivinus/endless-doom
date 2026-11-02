class_name Humanoid extends CharacterBody3D

const REFERENCE_MASS: float = 10.0

@export_group("Stats")
@export var move_speed: float = 2.5
@export var max_health: float = 100.0
@export var mass: float = 10.0
@export var health: float:
	set(value):
		if is_dead: return
		health = clamp(value, 0, max_health)
		property_changed.emit("health", health)
		if health <= 0:
			is_dead = true
			on_died.emit()
			
@export_group("Movement")
@export var use_acceleration: bool = false
@export var accel: float
@export var deaccel: float
@export var auto_rotate: bool ##If set to True, face to moving direction
@export var rotation_speed: float = 5.0 ##Rad/sec

var is_dead: bool = false

#region Movement
const NEAREST_TARGET_LENGTH = 0.05
var cur_speed: float = 0.0
var is_moving_paused: bool = false
var speed: float = 0.0
var is_moving: bool = false
var move_dir: Vector3 = Vector3.ZERO
var last_move_dir: Vector3 = Vector3.ZERO
var move_target = null

var knockback_instance: KnockbackInstance
#endregion 

signal on_hurt(amount: float)
signal on_died()
signal on_pick_up(item: Item)
signal move_to_finished(vector3: Vector3)
signal property_changed(property_name: String, value: Variant)

class KnockbackInstance:
	const DEACCEL = 8
	
	var knockback_velocity: Vector3
	var parent: Humanoid
	
	func  _init(init_parent: Humanoid) -> void:
		parent = init_parent
	
	func _process(delta: float) -> void:
		parent.velocity += knockback_velocity
		
		if parent.is_on_wall():
			stop()
		
		if knockback_velocity == Vector3.ZERO: return
		knockback_velocity.x = move_toward(knockback_velocity.x, 0.0, DEACCEL * delta)
		knockback_velocity.y = move_toward(knockback_velocity.y, 0.0, DEACCEL * delta)
		knockback_velocity.z = move_toward(knockback_velocity.z, 0.0, DEACCEL * delta)
	
	func launch(velocity: Vector3) -> void:
		knockback_velocity = velocity
		knockback_velocity.y = 0
	
	func launch_y(velocity: float) -> void:
		knockback_velocity.y = velocity
	
	func stop() -> void:
		knockback_velocity = Vector3.ZERO

func _ready() -> void:
	health = max_health
	knockback_instance = KnockbackInstance.new(self)

func _physics_process(delta: float) -> void:
	_process_moving(delta)
	_process_gravity(delta)
	knockback_instance._process(delta)
	move_and_slide()

func _process_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func _process_moving(delta: float) -> void:
	if is_dead:
		velocity.x = 0
		velocity.z = 0
		last_move_dir = Vector3.ZERO
		cur_speed = 0.0
		stop_move()
		return
	
	if is_moving: 
		if move_target:
			move_dir = global_position.direction_to(move_target)
			move_dir.y = 0
			move_dir = _modify_move_dir(move_dir.normalized())
			
			var flat_self = Vector2(global_position.x, global_position.z)
			var flat_target = Vector2(move_target.x, move_target.z)
			
			if flat_self.distance_squared_to(flat_target) <= NEAREST_TARGET_LENGTH:
				var prev_target = move_target
				stop_move()
				move_to_finished.emit(prev_target)
	else:
		move_dir = Vector3.ZERO
			
	if move_dir != Vector3.ZERO:
		cur_speed = move_toward(cur_speed, move_speed, accel * delta)
		last_move_dir = move_dir
	else:
		cur_speed = move_toward(cur_speed, 0.0, deaccel * delta)
	_face_rotation(last_move_dir, delta)
	
	if use_acceleration:
		velocity.x = cur_speed * last_move_dir.x
		velocity.z = cur_speed * last_move_dir.z
	else :
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed

func  _face_rotation(dir: Vector3, delta: float) -> void:
	if dir == Vector3.ZERO or not auto_rotate or not is_moving: return
	var angle = atan2(-dir.x, -dir.z)
	rotation.y = lerp_angle(rotation.y, angle, rotation_speed * delta)

func get_enemy_floor_Y_offset() -> float:
	var col: CollisionShape3D = $CollisionShape3D
	return (col.shape.height / 2.0) - col.position.y - 0.1

func move_to(target_pos: Vector3) -> void:
	if is_moving_paused: return
	move_target = target_pos
	is_moving = true

func move_to_direction(direction: Vector3) -> void:
	if is_moving_paused: return
	if not direction.is_normalized():
		direction = direction.normalized()
	
	move_dir = Vector3(direction.x, 0, direction.z)
	is_moving = true

func pause_move() -> void:
	if not is_moving: return #or move_dir == Vector3.ZERO
	is_moving_paused = true
	is_moving = false
	
func continue_move() -> void:
	if not is_moving_paused: return
	is_moving_paused = false
	if move_target == null:
		is_moving = false
		return
	is_moving = true

func stop_move() -> void:
	move_dir = Vector3.ZERO
	is_moving = false
	is_moving_paused = false
	move_target = null

func knockback(force: Vector3) -> void:
	var force_factor: float = REFERENCE_MASS/maxf(mass, 0.01)
	force = force * force_factor
	
	knockback_instance.launch(force)

func _modify_move_dir(dir: Vector3) -> Vector3:
	return dir

func get_facing_direction() -> Vector3:
	return -global_transform.basis.z

func hurt(damage: float, ..._args: Array) -> void:
	if is_dead: return
	health -= damage
	if not is_dead: on_hurt.emit(damage)

func is_movement_blocked(length: float) -> bool:
	if move_dir == Vector3.ZERO: return false
	var target: Vector3 = global_position + move_dir * length
	var raycast = Raycast3d.new(self)
	raycast.from_to(global_position, target)
	raycast.mask([2, 4])
	var query = raycast.intersect()
	return not query.is_empty()
