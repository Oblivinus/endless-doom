class_name WaveManager extends Node

var initial_spawn_interval: float = 0.5

@export var enemy_spawn_pos: Array[Marker3D]
@export var enemy_patrol_pos: Array[Marker3D]
@export var enemy_wave_entries: Array[WaveEntry]

var enemies_parent: Node
var current_wave: int = 0

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

func _ready() -> void:
	enemies_parent = Node.new()
	enemies_parent.name = "Enemies"
	get_parent().add_child.call_deferred(enemies_parent)
	
	between_wave = Timer.new()
	between_wave.one_shot = true
	between_wave.wait_time = 1
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

func _roll_entry(wave: int) -> WaveEntry:
	var total: float = 0.0
	var available: Array[WaveEntry] = []

	for entry in enemy_wave_entries:
		if wave >= entry.wave_appear and entry.weight > 0.0:
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
	max_alive = min(max_alive, 50)
#endregion

#region WAVE
func get_remaining_enemy() -> int:
	return (max_enemies - total_enemies) + alive.size()

func next_wave() -> void:
	if ongoing: return
	print("Wave %d" % [get_current_wave()])
	
	_calculate_wave()
	
	total_enemies = 0
	ongoing = true
	highlight_triggered = false
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

#endregion
