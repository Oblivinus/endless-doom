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
@export var fov: int = 90

@export_category("Movement")
@export var steer_y_origin_offset: float = -0.75

@export_category("Resources")

var timer: Timer

@export var in_sight_sfx: Array[String] = ["possessed/possessed_sight 1", "possessed/possessed_sight 2", "possessed/possessed_sight 3"]
@export var idle_sfx: Array[String] = ["possessed/possessed_death 1", "possessed/possessed_death 2", "possessed/possessed_death 3"]
@export var dead_sfx: Array[String] = ["possessed/possessed_activity"]
@export var hurt_sfx: Array[String] = ["possessed/possessed_pain"]

signal on_hurt_ex(dmg_info: DamageInfo)
signal on_pain()
signal on_attack
signal event (event_name: String)

var range_attack_area: Area3D
var melee_attack_area: Area3D
var pathfind: Pathfind

#region IN COMBAT
@export_category("In Combat")
@export var attack_delay: float = 0.7
var attack_timer: Timer
var attack_pos: Vector3 = Vector3.ZERO
var is_attacking: bool = false
var has_melee: bool = false
var has_range: bool = false

var is_disturbed: bool = false
var in_pain: bool = false
var prev_dmg_info: DamageInfo
#endregion

class Pathfind:
	var has_target: bool = false
	var target_pos: Vector3
	var humanoid: Humanoid
	
	var nav_agent: NavigationAgent3D
	
	func _init(parent: Humanoid) -> void:
		humanoid = parent
		
		var feet := Node3D.new()
		feet.position = Vector3(0, -humanoid.get_enemy_floor_Y_offset(), 0)   # same as steer_y_origin_offset
		humanoid.add_child(feet)
		
		nav_agent = NavigationAgent3D.new()
		nav_agent.debug_enabled = false
		nav_agent.path_desired_distance = 0.5
		nav_agent.target_desired_distance = 0.5
		feet.add_child(nav_agent)
	
	func navigate(target: Vector3):
		has_target = true
		target_pos = target
		nav_agent.target_position = target_pos
	
	func process(_delta: float):
		if not has_target: return
		var next_path_pos = nav_agent.get_next_path_position()
		
		humanoid.move_to(next_path_pos)
		
		if nav_agent.is_navigation_finished():
			stop()
			humanoid.stop_move()
	
	func stop():
		has_target = false
		nav_agent.target_position = humanoid.global_position

func _ready() -> void:
	super()
	pathfind = Pathfind.new(self)
	
	state_machine.init(self)
	set_collision_layer_value(3, true)
	
	on_died.connect(_on_died, CONNECT_ONE_SHOT)
	on_hurt.connect(_on_hurt)
	on_hurt_ex.connect(_on_hurt_ex)
	on_attack.connect(_on_attack)
	event.connect(_on_event)
	
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_cd
	add_child(attack_timer)
	
	if attack_range > 0:
		range_attack_area = _create_range_area(FrustumShape.new(Vector2(0.5, 1), 0, 45, attack_range))
		add_child(range_attack_area)
		has_range = true
	if melee_range > 0:
		melee_attack_area = _create_range_area(FrustumShape.new(Vector2(1.5, 2), 0, 0, melee_range))
		add_child(melee_attack_area)
		has_melee = true

func _process_moving(delta: float) -> void:
	if in_pain: is_disturbed = true
	if in_pain and not is_moving_paused:
		pause_move()
	elif not in_pain and is_moving_paused:
		continue_move()
	super(delta)

func _physics_process(delta: float) -> void:
	pathfind.process(delta)
	$Sprite3D.modulate = lerp($Sprite3D.modulate, Color.WHITE, delta * 5)
	super(delta)

func hurt(damage: float, ...args:Array) -> void:
	var dmg_info : DamageInfo = args[0]
	if not is_dead: on_hurt_ex.emit(dmg_info)
	super(damage)

##region STEERING
#var avoid_side: int = 0               # 0 = not avoiding, -1 / 1 = locked side
#var avoid_step: int = 1               # current detour angle = step * AVOID_STEP_DEG
#var avoid_clear_time: float = 0.0
#var avoid_release_time: float = 0.4  # how long the direct path must stay clear before we stop detouring
#var avoid_look_ahead: float = 2.0
#var avoid_radius: float = 0.7
#const AVOID_STEP_DEG := 30.0
#const AVOID_MAX_STEPS := 5
#
#func _modify_move_dir(desired: Vector3) -> Vector3:
	#if desired == Vector3.ZERO: return desired
	#var delta := get_physics_process_delta_time()
#
	## Direct path is clear
	#if not _ray_blocked(desired, avoid_look_ahead):
		#if avoid_side == 0:
			#return desired
		## Still detouring: keep the same turn a bit longer so the body clears the corner
		#avoid_clear_time += delta
		#if avoid_clear_time >= avoid_release_time:
			#avoid_side = 0
			#avoid_clear_time = 0.0
			#return desired
		#var held := _rotate_dir(desired, avoid_step, avoid_side)
		#return desired if _ray_blocked(held, avoid_look_ahead) else held
		#
	#avoid_clear_time = 0.0
	#if avoid_side == 0:
		#avoid_side = [-1, 1].pick_random()
#
	#for attempt in 2:
		#for step in range(1, AVOID_MAX_STEPS + 1):
			#var dir := _rotate_dir(desired, step, avoid_side)
			#if not _ray_blocked(dir, avoid_look_ahead):
				#avoid_step = step
				#return dir
		#avoid_side = -avoid_side
	#
	##NOTE: Stop move no path to it
	#print("not path")
	#stop_move()
	#return desired
#
#func _rotate_dir(dir: Vector3, step: int, side: int) -> Vector3:
	#return dir.rotated(Vector3.UP, deg_to_rad(AVOID_STEP_DEG * step) * side)
#
#func _ray_blocked(dir: Vector3, length: float) -> bool:
	#var side_offset := dir.cross(Vector3.UP).normalized() * avoid_radius
	#for offset in [Vector3.ZERO, side_offset, -side_offset]:
		#var origin: Vector3 = global_position + offset
		#var raycast = Raycast3d.new(self)
		#
		#origin.y += steer_y_origin_offset
		#raycast.from_to(origin, origin + dir * length)
		#raycast.mask([2, 4])
		#if not raycast.intersect().is_empty():
			#return true
	#return false
#
#func stop_move() -> void:
	#super()
	#avoid_side = 0
	#avoid_clear_time = 0.0
##endregion

#region CONNECTION
func _on_hurt(_dmg: float) -> void:
	flash_sprite(Color(1.0, 0.166, 0.09, 1.0))
	_process_pain()

func _on_hurt_ex(dmg_info: DamageInfo):
	if dmg_info:
		prev_dmg_info = dmg_info
	else:
		prev_dmg_info = null

func _on_died() -> void:
	state_machine.change_state_name("dead")
	Globals.any_enemy_died(self, global_position)
	play_sound("dead")

func _on_event(event_name) -> void:
	if event_name == "in_sight":
		play_sound("in_sight")
	if event_name == "random_idle":
		play_sound("idle")

func _on_attack():
	pass

func _on_missed_or_blocked(pos: Vector3 = Vector3.ZERO, context: String = "none") -> void:
	pass

func _attack_sequeance(current_distance: float):
	if is_dead or is_disturbed: return
	
	if has_melee and current_distance <= melee_range:
		melee_attack_action();
		return
	
	if has_range and current_distance <= attack_range:
		attack_action();
		return

#endregion

#region HELPER
func _is_path_clear(target_pos: Vector3, radius: float = 0.7) -> bool:
	var y_offset := Vector3(0, -0.75, 0)
	var from := global_position + y_offset
	var to := target_pos + y_offset

	var dir := to - from
	dir.y = 0
	if dir.is_zero_approx():
		return true

	# Perpendicular to the travel direction on the XZ plane
	var side := dir.normalized().cross(Vector3.UP) * radius

	for offset in [Vector3.ZERO, side, -side]:
		var raycast = Raycast3d.new(self)
		raycast.from_to(from + offset, to + offset)
		raycast.mask([2, 4])
		if not raycast.intersect().is_empty():
			return false
	return true

func _process_pain() -> void:
	var new_pain_chance = pain_chance
	
	if prev_dmg_info:
		new_pain_chance = pain_chance * prev_dmg_info.pain_modifier
	
	if randf() > new_pain_chance: return
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

func _raycast_check(final_pos: Vector3) -> Dictionary:
	var raycast = Raycast3d.new(self)
	raycast.from_to(global_position, final_pos)
	raycast.mask([2])
	var result = raycast.intersect()
	return result

func _check_for_target() -> Humanoid:
	var targets = get_enemies_in_attack_range()
	if targets.is_empty(): return null
	
	for humanoid: Humanoid in targets:
		var query = _raycast_check(humanoid.global_position)
		if query.is_empty():
			return humanoid
		else:
			var intersect: Vector3 = query.position
			_on_missed_or_blocked(intersect, "range")
			return
	_on_missed_or_blocked()
	return null

func _check_for_target_in_melee() -> Humanoid:
	var targets = get_enemies_in_melee_range()
	if targets.is_empty(): return null
	
	for humanoid: Humanoid in targets:
		var query = _raycast_check(humanoid.global_position)
		if query.is_empty():
			return humanoid
		else:
			var intersect: Vector3 = query.position
			_on_missed_or_blocked(intersect, "melee")
			return
	_on_missed_or_blocked()
	return null



#endregion

#region METHOD
func move(target_pos: Vector3):
	if _is_path_clear(target_pos, 0.7):
		pathfind.stop()
		move_to(target_pos)
	else:
		navigate_to(target_pos)

func navigate_to(target_pos: Vector3):
	pathfind.navigate(target_pos)

func stop_move() -> void:
	super()
	pathfind.stop()

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
	#await get_tree().create_timer(0.15).timeout
	#$Sprite3D.modulate = Color.WHITE

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
#endregion

#region ATTACK METHOD
func attack_at_position(target_pos: Vector3) -> void:
	if in_pain or is_on_cooldown() or is_attacking: return
	
	var target_no_y := Vector3(target_pos.x, global_position.y, target_pos.z)
	var current_distance: float = get_target_distance()
	
	on_attack.emit()
	attack_timer.start()
	look_at(target_no_y)
	stop_move()
	is_disturbed = false
	is_attacking = true
	attack_pos = target_pos
	
	await get_tree().create_timer(attack_delay).timeout
	_attack_sequeance(current_distance)
	is_attacking = false

func is_on_cooldown() -> bool:
	return attack_timer.time_left > 0

func attack_action() -> void:
	pass

func melee_attack_action() -> void:
	pass

func get_target_distance() -> float:
	if not target: return -1
	var target2d = Vector2(target.global_position.x, target.global_position.z)
	var origin2d = Vector2(global_position.x, global_position.z)
	
	return origin2d.distance_to(target2d)
#endregion
