@abstract
class_name Enemy extends Humanoid

@export_category("Dependecies")
@export var animation_tree: ZombieAnimTree
@export var audio_player: AudioStreamPlayer3D
@export var state_machine: StateMachine
@export var hitbox: Area3D

@export_category("Combat")
@export var target: Humanoid
@export var attack_cd: float = 4.0
@export var attack_range: float = 10.0
@export var detection_range_multiplier: float = 2
@export var detection_range: float = 12.0

@export_category("Resources")
@export var sounds: Dictionary[String, AudioStream]

signal on_attack
var timer: Timer

func _ready() -> void:
	var collision_shape: CollisionShape3D = hitbox.find_child("CollisionShape3D")
	collision_shape.shape.size.z = 0
	collision_shape.shape.size += Vector3(0, 0, attack_range)
	collision_shape.position += Vector3(0, 0, -attack_range/2)
	state_machine.init(self)
	set_collision_layer_value(3, true)
	on_died.connect(func(): state_machine.change_state_name("dead"))
	on_hurt.connect(_on_hurt)

func _process_moving(delta: float) -> void:
	if is_hurted and not is_moving_paused:
		pause_move()
	elif not is_hurted and is_moving_paused:
		continue_move()
	super(delta)

func _on_hurt(_dmg: float):
	is_hurted = true
	animation_tree.travel("hurt")
	$Sprite3D.modulate = Color("ffb3b3ff")
	await get_tree().create_timer(0.25).timeout
	is_hurted = false
	$Sprite3D.modulate = Color.WHITE

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
