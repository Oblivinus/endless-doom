class_name Humanoid extends CharacterBody3D

@export_category("Stats")
@export var move_speed: float = 2.5
@export var max_health: float = 100.0
@export var health: float = max_health:
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			is_dead = true
			on_died.emit()
			
@export_category("Movement")
@export var use_acceleration: bool = false
@export var accel: float
@export var deaccel: float
@export var auto_rotate: bool ##If set to True, face to moving direction
@export var rotation_speed: float = 5.0 ##Rad/sec

var is_dead: bool = false
var is_hurted: bool = false

#region Movement
const NEAREST_TARGET_LENGTH = 0.05
var cur_speed: float = 0.0
var is_moving_paused: bool = false
var speed: float = 0.0
var is_moving: bool = false
var move_dir: Vector3 = Vector3.ZERO
var last_move_dir: Vector3 = Vector3.ZERO
var move_target = null
#endregion 

signal on_hurt(amount: float)
signal on_died()
signal move_to_finished(vector3: Vector3)


func _ready() -> void:
	health = max_health

func  _physics_process(delta: float) -> void:
	_process_moving(delta)
	_process_gravity(delta)
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
			
			var flat_self = Vector2(global_position.x, global_position.z)
			var flat_target = Vector2(move_target.x, move_target.z)
			
			if flat_self.distance_squared_to(flat_target) <= NEAREST_TARGET_LENGTH:
				var prev_target = move_target
				global_position.x = move_target.x
				global_position.z = move_target.z
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
	if not is_moving or move_dir == Vector3.ZERO: return
	is_moving_paused = true
	is_moving = false
	
func continue_move() -> void:
	if not is_moving_paused: return
	is_moving_paused = false
	is_moving = true

func stop_move() -> void:
	move_dir = Vector3.ZERO
	is_moving = false
	move_target = null

func get_facing_direction() -> Vector3:
	return -global_transform.basis.z

func hurt(damage: float) -> void:
	on_hurt.emit(damage)
	health -= damage
