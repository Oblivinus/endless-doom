class_name PainElemental extends FlyingEnemy

@export var spawn_distance: float = 1.3

func _process_gravity(delta):
	if is_dead:
		velocity.y = 0

func attack_action() -> void:
	var spawn_offset = global_position + (-global_basis.z * 1.2)
	LostSoul.spawn_to_attack(target, spawn_offset, get_parent(), attack_pos, 18)

func _on_died() -> void:
	super()
	for dir in get_spread_directions(3):
		var spawn_pos := global_position + dir * spawn_distance
		var dash_target := spawn_pos + dir
		LostSoul.spawn_to_attack(target, spawn_pos, get_parent(), dash_target, 18)

func get_spread_directions(count: int) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var start_angle := randf() * TAU
	for i in count:
		var angle := start_angle + (TAU / count) * i
		var dir := Vector3.FORWARD.rotated(Vector3.UP, angle)
		dir.y = 0.3
		result.append(dir.normalized())
	return result
