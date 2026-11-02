class_name WaveManager extends Node

const INTERMISSION_TIME: int = 10
const INIT_WAVE: int = 9

var initial_spawn_interval: float = 0.5

@export var enemy_spawn_pos: Array[Marker3D]
@export var enemy_patrol_pos: Array[Marker3D]
@export var enemy_wave_entries: Array[WaveEntry]
var boss_entries: Array[BossEntry] = []

var enemies_parent: Node
var current_wave: int = INIT_WAVE

var max_enemies: int = 10
var total_enemies: int = 0

var alive: Array[Enemy] = []
var max_alive: int = 10

var ongoing: bool = false
var between_wave: Timer
var spawn_timer: Timer

var highlight_triggered: bool = false
var highlight_threshold: int = 6
var highlights: Array[MeshInstance3D] = []

var disk_waves_entries: Dictionary

signal wave_finished
signal wave_start

#region UI

@export var wave_name: Label
@export var remaining_label: Label

func _process_ui():
	wave_name.text = "WAVE " + str(get_current_wave())
	
	if between_wave.time_left > 0:
		remaining_label.text = str(ceili(between_wave.time_left))
	elif ongoing:
		remaining_label.text = str(max_enemies - get_remaining_enemy()) + " / " + str(max_enemies)
	else:
		remaining_label.text = ""

#endregion

var new_normal_entry: Array[WaveEntry] = []
var new_boss_entry: Array[BossEntry] = []

func _ready() -> void:
	disk_waves_entries = GameData.get_wave_entries()
	var normal_entries: Array[WaveEntry] = []
	
	for entry_name in disk_waves_entries:
		var entry: WaveEntry = _create_entry_res(entry_name)
		if entry is BossEntry: boss_entries.append(entry)
		else: normal_entries.append(entry)
	
	enemy_wave_entries = normal_entries
	
	enemies_parent = Node.new()
	enemies_parent.name = "Enemies"
	get_parent().add_child.call_deferred(enemies_parent)
	
	between_wave = Timer.new()
	between_wave.one_shot = true
	between_wave.wait_time = INTERMISSION_TIME
	add_child(between_wave)
	
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.wait_time = initial_spawn_interval
	add_child(spawn_timer)
	
	between_wave.timeout.connect(next_wave)
	between_wave.start()

func _physics_process(_delta: float) -> void:
	alive = alive.filter(_filter_alive)
	
	_process_wave()
	_check_hightlight_remaining()
	_process_ui()
	
	if is_wave_cleared():
		finish()

#region PRIVATE
func _process_wave():
	spawn_next()

func _reset_boss_entries() -> void:
	for entry in boss_entries:
		entry.total_count = 0

func _roll_entry(wave: int) -> WaveEntry:
	var total: float = 0.0
	var available: Array[WaveEntry] = []
	
	if not boss_entries.is_empty():
		for entry in boss_entries:
			var boss = _spawn_boss_entry(wave, entry)
			if boss: return boss
	
	for entry in enemy_wave_entries:
		if wave >= entry.wave_appear - 1 and entry.weight > 0.0:
			total += entry.weight
			available.append(entry)
	
	if available.is_empty():
		return null

	var chance: float = randf() * total
	for entry in available:
		chance -= entry.weight
		if chance < 0.0:
			return entry

	return available.back()

func _spawn_boss_entry(wave: int, entry: BossEntry) -> BossEntry:
	var wave_number = wave + 1
	if wave_number < entry.wave_appear: return null
	if (wave_number - entry.wave_appear) % entry.wave_step != 0: return null
	if entry.total_count >= entry.max_alive: return  null
	if total_enemies < entry.appear_after: return null
	
	print("Boss Appeared")
	entry.total_count += 1
	return entry

func _filter_alive(obj) -> bool:
	var valid = true
		
	if obj is Humanoid and obj.is_dead:
		valid = false
	else:
		valid = not obj.is_queued_for_deletion() or is_instance_valid(obj)
		
	return valid

func _calculate_wave() -> void:
	max_enemies = int( 10 + current_wave * 6 + pow(current_wave, 1.35) )
	max_alive = int( 10 + (current_wave * 5) )
	
	max_enemies = min(max_enemies, 120)
	max_alive = min(max_alive, 45)
#endregion

#region WAVE DATA INIT

func _create_entry_res(entry_key: StringName) -> WaveEntry:
	
	var enemy_scene: PackedScene = Ref.get_enemy_scene_by_name(entry_key)
	assert(enemy_scene != null, "Enemy Scene don't exist")
	assert(disk_waves_entries.has(entry_key), "Entry Don't exist")
	var disk_entry_data: Dictionary = disk_waves_entries[entry_key]
	
	var entry: WaveEntry
	if disk_entry_data.get("boss", false):
		entry = BossEntry.new()
	else:
		entry = WaveEntry.new()
	
	entry.enemy_scene = enemy_scene
	entry.wave_appear = disk_entry_data.get("wave_appeared", 1)
	entry.weight = disk_entry_data.get("weight", 0.0)
	entry.max_alive = disk_entry_data.get("max_alive", -1)
	
	if not entry is BossEntry: return entry
	
	entry.wave_step = disk_entry_data.get("wave_step", 5)
	entry.appear_after = disk_entry_data.get("appear_after", 10)
	entry.wave_plus_max_alive = disk_entry_data.get("wave_plus_max_alive", 10)
	entry.max_alive = max(disk_entry_data.get("max_alive", 1), 1)
	
	return entry

#endregion

#region WAVE
func get_remaining_enemy() -> int:
	return (max_enemies - total_enemies) + alive.size()

func next_wave() -> void:
	if ongoing: return
	print("Wave %d" % [get_current_wave()])
	
	_calculate_wave()
	_reset_boss_entries()
	
	total_enemies = 0
	ongoing = true
	wave_start.emit()

func finish():
	current_wave += 1
	ongoing = false
	wave_finished.emit()
	between_wave.start()
	
	_clear_hl()
	print("Cleared")

func is_wave_cleared() -> bool:
	var reach_enemy_total: bool = total_enemies >= max_enemies
	var no_more_alive: bool = alive.size() == 0
	
	return reach_enemy_total and no_more_alive and ongoing

func get_current_wave() -> int:
	return current_wave + 1

func spawn_next():
	if not spawn_timer.is_stopped() or not ongoing: return
	if total_enemies >= max_enemies: return
	if alive.size() >= max_alive: return
	
	total_enemies += 1
	
	var enemy: Enemy = roll_to_spawn().enemy_scene.instantiate() as Enemy
	enemy.position = enemy_spawn_pos.pick_random().global_position
	enemies_parent.add_child(enemy)
	
	alive.append(enemy)
	spawn_timer.start()
	
	if highlight_triggered:
		_highlight_enemy(enemy)
	
	var patrol_pos = enemy_patrol_pos.pick_random().global_position
	patrol_pos.x += randi_range(-10, 10)
	patrol_pos.z += randi_range(-10, 10)

	if enemy is FlyingEnemy:
		patrol_pos.y = enemy.global_position.y
	else:
		var nav_map: RID = enemy.get_world_3d().navigation_map
		patrol_pos = NavigationServer3D.map_get_closest_point(nav_map, patrol_pos)

	await get_tree().physics_frame
	await get_tree().physics_frame
	if is_instance_valid(enemy) and not enemy.is_dead:
		enemy.move(patrol_pos)

func roll_to_spawn() -> WaveEntry:
	return _roll_entry(current_wave)

func simulate_wave(wave: int, count: int = max_enemies) -> Dictionary[String, int]:
	var result: Dictionary[String, int] = {}
	for i in count:
		var entry := _roll_entry(wave)
		if entry == null: continue
		var enemy_name: String = entry.enemy_scene.resource_path.get_file().get_basename()
		result[enemy_name] = result.get(enemy_name, 0) + 1
	return result
#endregion

#region HIGHLIGHT
func _check_hightlight_remaining() -> void:
	if highlight_triggered or not ongoing: return
	
	if get_remaining_enemy() > highlight_threshold: return
	
	highlight_triggered = true
	for enemy in alive:
		_highlight_enemy(enemy)

func _highlight_enemy(enemy: Enemy) -> void:
	
	if enemy.has_node("HL"): return
	var highlight = Ref.highlight_3d.instantiate()
	highlight.name = "HL"
	highlights.append(highlight)
	enemy.add_child(highlight)

func _clear_hl():
	for hl in highlights:
		if not is_instance_valid(hl): continue
		if hl.is_queued_for_deletion(): continue
		hl.queue_free()
	highlights.clear()
	highlight_triggered = false

#endregion
