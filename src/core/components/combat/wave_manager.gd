class_name WaveManager extends Node


@export var enemy_spawn_pos: Array[Marker3D]
@export var enemy_patrol_pos: Array[Marker3D]
@export var enemy_wave_entries: Array[WaveEntry]

var enemies_parent: Node
var current_wave: int = 0

var max_enemies: int = 10
var total_enemies: int = 0
var max_current_amount = 10
var alive: Array[Enemy] = []

var ongoing: bool = false
var between_wave: Timer

signal wave_finished
signal wave_start

func _ready() -> void:
	enemies_parent = Node.new()
	enemies_parent.name = "Enemies"
	get_parent().add_child.call_deferred(enemies_parent)
	
	between_wave = Timer.new()
	between_wave.one_shot = true
	between_wave.wait_time = 30
	add_child(between_wave)

func next_wave():
	current_wave += 1
	ongoing = true
	wave_start.emit()

func finish():
	ongoing = false
	wave_finished.emit()

func roll_to_spawn():
	pass

func spawn(entry: WaveEntry):
	pass
