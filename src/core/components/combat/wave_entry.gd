class_name WaveEntry extends Resource

@export var enemy_scene: PackedScene
@export var wave_appear: int
@export var spawn_interval: float = 0.5

@export var initial_amount: int
@export var amount_increment: int
@export var amount_cap: int
@export var max_amount_available: int
@export var max_amount_increment: int

var wave_manager: WaveManager
var current_amount: int = 0
var alive: Array[Enemy] =[]

var current_time: float = 0

func _is_requirement_met() -> bool:
	var world: bool = Globals.world != null
	var is_debut_wave: bool = wave_manager.current_wave >= wave_appear
	var is_available_to_spawn = alive.size() <= max_amount_available
	
	return wave_manager and world and is_debut_wave and is_available_to_spawn

func spawn() -> void:
	if not _is_requirement_met(): return
	if current_time < spawn_interval: return
	current_time = 0
	
	var enemy: Enemy = enemy_scene.instantiate()
	var rand_spawn: Vector3 = wave_manager.enemy_spawn_pos.pick_random().global_position
	var rand_patrol: Vector3 = wave_manager.enemy_patrol_pos.pick_random().global_position
	
	enemy.position = rand_spawn
	wave_manager.enemies_parent.add_child(enemy)

func init(manager: WaveManager = null):
	wave_manager = manager
