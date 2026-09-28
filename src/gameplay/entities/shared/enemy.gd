@abstract
class_name Enemy extends Humanoid

@export_category("Dependecies")
@export var animation_tree: AnimationTree
@export var state_machine: StateMachine

@export_category("Combat")
@export var target: Humanoid
@export var attack_cd: float = 4.0
@export var attack_damage: float = 5.0
@export var melee_damage: float = 6.0
@export var pain_chance: float = 0.8
@export var pain_time: float = 0.17

@export_category("Range")
@export var detection_range: float = 12.0
@export var attack_range: float = 10.0
@export var melee_range: float = 0.0
@export var fov: int = 45

@export_category("Resources")
@export var sounds: Dictionary[String, AudioStream]

var timer: Timer
var in_pain: bool = false

@export var in_sight_sfx: Array[String] = ["possessed/possessed_sight 1", "possessed/possessed_sight 2", "possessed/possessed_sight 3"]
@export var idle_sfx: Array[String] = ["possessed/possessed_death 1", "possessed/possessed_death 2", "possessed/possessed_death 3"]
@export var dead_sfx: Array[String] = ["possessed/possessed_activity"]
@export var hurt_sfx: Array[String] = ["possessed/possessed_pain"]

signal on_pain()
signal on_attack
signal event (event_name: String)

var range_attack_area: Area3D
var melee_attack_area: Area3D

func _ready() -> void:
	super()
	
	state_machine.init(self)
	set_collision_layer_value(3, true)
	
	on_died.connect(_on_died)
	on_hurt.connect(_on_hurt)
	event.connect(_on_event)
	
	if attack_range > 0:
		range_attack_area = _create_range_area(FrustumShape.new(Vector2(0.5, 1), 0, 45, attack_range))
		add_child(range_attack_area)
	if melee_range > 0:
		melee_attack_area = _create_range_area(FrustumShape.new(Vector2(1.5, 2), 0, 0, melee_range))
		add_child(melee_attack_area)

func _process_moving(delta: float) -> void:
	if is_hurted and not is_moving_paused:
		pause_move()
	elif not is_hurted and is_moving_paused:
		continue_move()
	super(delta)

func hurt(damage: float, type: String = "normal", dir: Vector3 = Vector3.ZERO) -> void:
	super(damage)

#region CONNECTION
func _on_hurt(_dmg: float) -> void:
	flash_sprite(Color(1.0, 0.316, 0.252, 1.0))
	_process_pain()

func _on_died() -> void:
	state_machine.change_state_name("dead")
	Globals.any_enemy_died(self, global_position)
	play_sound("dead")

func _on_event(event_name) -> void:
	if event_name == "in_sight":
		play_sound("in_sight")
	if event_name == "random_idle":
		play_sound("idle")
#endregion

#region HELPER
func _process_pain() -> void:
	if randf() > pain_chance: return
	if not is_dead: play_sound("pain")
	in_pain = true
	is_hurted = true
	animation_tree.travel("hurt")
	await get_tree().create_timer(pain_time).timeout
	in_pain = false
	is_hurted = false

func _create_range_area(frustum_shape: FrustumShape) -> Area3D:
	var area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = (1 << 0)
	
	var area_shape = CollisionShape3D.new()
	area_shape.shape = frustum_shape
	area_shape.debug_color = Color(0.0, 1.0, 0.0, 1.0)
	area.add_child(area_shape)
	return area
#endregion

func get_enemies_in_attack_range() -> Array[Player]:
	if attack_range <= 0: return []
	var bodies = range_attack_area.get_overlapping_bodies()
	var players: Array[Player] = []
	for b in bodies:
		if b is Player:
			players.append(b)
	return players

func get_enemies_in_melee_range() -> Array[Player]:
	if melee_range <= 0: return []
	var bodies = melee_attack_area.get_overlapping_bodies()
	var players: Array[Player] = []
	for b in bodies:
		if b is Player:
			players.append(b)
	return players

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

func is_in_sight(target_pos: Vector3) -> bool:
	if get_facing_degree_to(target_pos) > fov:
		return false
	else:
		return true

func flash_sprite(color: Color):
	$Sprite3D.modulate = color
	await get_tree().create_timer(pain_time).timeout
	$Sprite3D.modulate = Color.WHITE

func play_sound(sound_name: String):
	var sound_array: Array
	var volume: float = -5.0
	
	if sound_name.to_lower() == "pain":
		sound_array = hurt_sfx
		volume = -7.0
	if sound_name.to_lower() == "dead":
		sound_array = dead_sfx
	if sound_name.to_lower() == "in_sight":
		sound_array = in_sight_sfx
	if sound_name.to_lower() == "idle":
		sound_array = idle_sfx
	
	if sound_array and not sound_array.is_empty():
		var audio = Audio3D.new(sound_array.pick_random(), self)
		audio.max_db = volume
		audio.max_distance = 35.0
		audio.play()
