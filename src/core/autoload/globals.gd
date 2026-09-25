extends Node

var isPause = false
var player_pos: Vector3
var player: CharacterBody3D
var world: Node3D

signal enemy_died(enemy: Enemy, last_pos: Vector3)

func _ready() -> void:
	world = get_tree().current_scene

func any_enemy_died(enemy: Enemy, last_pos: Vector3):
	var chance: float = randi_range(1, 2)
	enemy_died.emit(enemy, last_pos)
	
	for i: int in range(chance):
		spawn_item(last_pos)


func spawn_item(pos: Vector3):
	if not world: return
	
	var launch_vect: Vector3 = Vector3(0, 5, -5).normalized()  * 20
	var rand_angle: int = randi_range(-180, 180)
	
	launch_vect = launch_vect.rotated(Vector3.UP, deg_to_rad(rand_angle))
	
	var health_p = HealthPotion.create()
	health_p.position = pos
	world.add_child(health_p)
	health_p.apply_central_impulse(launch_vect)
