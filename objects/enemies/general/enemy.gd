@abstract
class_name Enemy extends CharacterBody3D

@export_category("Dependecies")
@export var animation_tree: AnimationTree
@export var audio_player: AudioStreamPlayer3D
@export var state_machine: StateMachine

@export_category("Stats")
@export var max_health: float = 100.0
@export var health: float = max_health
@export var died: bool = false
@export var move_speed: float = 2.0

@export_category("Combat")
@export var target: CharacterBody3D
@export var attack_cd: float = 4.0
@export var attack_range: float = 10.0
@export var detection_range_multiplier: float = 2
var detection_range: float = attack_range * detection_range_multiplier

@export_category("Resources")
@export var sounds: Dictionary[String, AudioStream]

signal on_died
signal on_hurt
var timer: Timer
var hurted: bool = false

#Move to variable
var this_pos: Vector3
var move_to_target: Vector3 = Vector3.ZERO
var is_moving: bool = false
const MOVE_TO_ARRIVAL_THRESHOLD: float = 0.05

func _ready() -> void:
	state_machine.init(self)
	set_collision_layer_value(3, true)
	on_died.connect(func(): state_machine.change_state_name("dead"))

func _physics_process(delta: float) -> void:
	_process_moving(delta)	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()

func _process_moving(_delta: float) -> void:
	if not is_moving or hurted:
		velocity.x = 0
		velocity.z = 0
		return

	var current_pos_2d := Vector2(global_position.x, global_position.z)
	var target_pos_2d := Vector2(move_to_target.x, move_to_target.z)
	var distance := current_pos_2d.distance_to(target_pos_2d)

	if distance <= MOVE_TO_ARRIVAL_THRESHOLD:
		is_moving = false
		move_to_target = Vector3.ZERO
		velocity.x = 0
		velocity.z = 0
		return

	var direction := current_pos_2d.direction_to(target_pos_2d)
	rotation.y = atan2(-direction.x, -direction.y)

	velocity.x = direction.x * move_speed
	velocity.z = direction.y * move_speed

func get_facing_direction() -> Vector3:
	return -global_transform.basis.z
	
func get_local_direction_to(target_pos: Vector3) -> Vector3:
	var to_player = (target_pos - global_position).normalized()
	var local_dir = global_transform.basis.inverse() * to_player
	
	return Vector3(local_dir.x, 0, local_dir.z)

func get_facing_degree_to(target_pos: Vector3) -> int:
	var to_target = (target_pos - global_position).normalized()
	var angle = get_facing_direction().angle_to(to_target)
	var degree = rad_to_deg(angle)
	return degree

func move_to(target_pos: Vector3) -> void:
	if is_moving: return
	
	move_to_target = target_pos
	is_moving = true

func change_move_to_direction(new_pos: Vector3):
	move_to_target = new_pos

func stop_move_to() -> void:
	if !is_moving: return
	
	move_to_target = Vector3.ZERO
	is_moving = false

func hurt(dmg: float) -> void:
	if died: return
	hurted = true
	$Sprite3D.modulate = Color("ffb3b3ff")
	
	get_tree().create_timer(0.25).timeout.connect(func(): 
		$Sprite3D.modulate = Color.WHITE
		hurted = false
		)
	health -= dmg
	on_hurt.emit()
	if health <= 0:
		on_died.emit()
