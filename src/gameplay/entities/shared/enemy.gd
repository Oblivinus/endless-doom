@abstract
class_name Enemy extends Humanoid

@export_category("Dependecies")
@export var animation_tree: GenericAnimationTree
@export var audio_player: AudioStreamPlayer3D
@export var state_machine: StateMachine
@export var hitbox: Area3D

@export_category("Combat")
@export var target: Humanoid
@export var attack_cd: float = 4.0
@export var attack_range: float = 10.0
@export var attack_damage: float = 5.0
@export var detection_range_multiplier: float = 2
@export var detection_range: float = 12.0

@export_category("Resources")
@export var sounds: Dictionary[String, AudioStream]

signal on_attack
signal event (event_name: String)
var timer: Timer

var in_sight_sfx: Array[String]
var idle_sfx: Array[String]
var dead_sfx: Array[String]
var hurt_sfx: Array[String]

func _ready() -> void:
	super()
	var collision_shape: CollisionShape3D = hitbox.find_child("CollisionShape3D")
	collision_shape.shape.size.z = 0
	collision_shape.shape.size += Vector3(0, 0, attack_range)
	collision_shape.position += Vector3(0, 0, -attack_range/2)
	state_machine.init(self)
	set_collision_layer_value(3, true)
	on_died.connect(_on_died)
	on_hurt.connect(_on_hurt)
	event.connect(_on_event)

func _process_moving(delta: float) -> void:
	if is_hurted and not is_moving_paused:
		pause_move()
	elif not is_hurted and is_moving_paused:
		continue_move()
	super(delta)

func _on_hurt(_dmg: float):
	if not is_dead: play_sound("pain")
	is_hurted = true
	animation_tree.travel("hurt")
	$Sprite3D.modulate = Color("ffb3b3ff")
	await get_tree().create_timer(0.25).timeout
	is_hurted = false
	$Sprite3D.modulate = Color.WHITE

func _on_died():
	state_machine.change_state_name("dead")
	play_sound("dead")

func _on_event(event_name):
	if event_name == "in_sight":
		play_sound("in_sight")
	if event_name == "random_idle":
		play_sound("idle")

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

func play_sound(sound_name: String):
	var sound_array: Array
	
	if sound_name.to_lower() == "pain":
		sound_array = hurt_sfx
	if sound_name.to_lower() == "dead":
		sound_array = dead_sfx
	if sound_name.to_lower() == "in_sight":
		sound_array = in_sight_sfx
	if sound_name.to_lower() == "idle":
		sound_array = idle_sfx
	
	if sound_array and not sound_array.is_empty():
		var audio = Audio3D.new(sound_array.pick_random(), self)
		audio.max_db = -5.0
		audio.play()
