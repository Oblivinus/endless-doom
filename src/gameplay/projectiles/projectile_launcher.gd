class_name ProjectileLauncher extends RefCounted

var projectile: Projectile

var on_hit: Array[Humanoid]

func _init(projectile_name: String, origin: Vector3) -> void:
	if not Ref.projectiles.has(projectile_name.to_lower()): 
		print("Projectile \"%s\" does not exist")
		return
	
	projectile = ObjPool.spawn(Ref.projectiles[projectile_name])
	projectile.activate(origin)

func launch(target_position: Vector3):
	var launch_direction = projectile.global_position.direction_to(target_position)
	projectile.launch(launch_direction)
