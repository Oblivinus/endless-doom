class_name CyberDemon extends Enemy

@export var volley_count: int = 3
@export var volley_interval: float = 0.3

func attack_action() -> void:
	var aim_pos := attack_pos
	
	for i in volley_count:
		if i > 0:
			await get_tree().create_timer(volley_interval).timeout
			
			if is_dead or is_disturbed: return
			
			if target: aim_pos = target.global_position
			animation_tree.start("attack")
		
		launch_rocket(aim_pos)

func get_enemy_floor_Y_offset() -> float:
	var col: CollisionShape3D = $CollisionShape3D
	var half_height: float = col.shape.height / 2.0
	return half_height - col.position.y - 0.1

func launch_rocket(pos: Vector3):
	var launcher = ProjectileLauncher.new("enemy_rocket", global_position)
	launcher.projectile.max_damage = attack_damage
	launcher.launch(pos)
