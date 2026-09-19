class_name Spawner extends Marker3D

@export var spawn_type: String
@export var interval: float = 0.5
@export var max_spawn: int = 10
@export var spawn_rate_flactuation: bool = false

var spawnable: Dictionary = {
	zombie = preload("res://src/gameplay/entities/enemies/zombie/zombie.tscn")
}

var floor_y: float = 1.25
var time_passed: float
var current_entities: Array[Humanoid] = []

func  _physics_process(delta: float) -> void:
	time_passed += delta
	
	if not current_entities.is_empty():
		current_entities = current_entities.filter(func(obj): return is_instance_valid(obj))
	
	if time_passed >= interval:
		if current_entities.size() > max_spawn: return
		spawn(spawn_type, random_pos())
		time_passed = 0

func spawn(id: String, pos: Vector3) -> Humanoid:
	if not spawnable.has(id.to_lower()): return
	
	var scene: PackedScene = spawnable[id]
	var instance: Humanoid = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = pos
	current_entities.append(instance)
	return instance

func random_pos():
	var x: int = randi_range(2, 10)
	var z: int = randi_range(2, 10)
	var direction: Array[int] = [-1, 1]
	
	var vec3 = Vector3(x * direction.pick_random(), 0, z * direction.pick_random())
	var result = global_position + vec3
	result.y = floor_y
	return result
