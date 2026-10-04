class_name WaveManager extends Node3D


@export var enemy_spawn_pos: Array[Marker3D]
@export var enemy_patrol_pos: Array[Marker3D]
@export var enemy_wave_entries: Array[WaveEntry]

var enemies_parent: Node
var current_wave: int = 1

func _ready() -> void:
	enemies_parent = Node.new()
	enemies_parent.name = "Enemies"
	add_child(enemies_parent)
	
	for wave_entry: WaveEntry in enemy_wave_entries:
		wave_entry.init(self)
