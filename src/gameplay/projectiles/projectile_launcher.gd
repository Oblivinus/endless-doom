class_name ProjectileLauncher extends RefCounted

var projectile: Projectile

var on_hit: Array[Humanoid]

func _init(projectile_name: String, origin: Vector3) -> void:
	if not Ref.projectiles.has(projectile_name.to_lower()): 
		print("Projectile \"%s\" does not exist")
		return
	
	var projectile_packed: PackedScene = Ref.projectiles[projectile_name]
	var projectile_scene: Projectile = projectile_packed.instantiate()
	projectile = projectile_scene
	Globals.world.add_child(projectile)
	projectile.global_position = origin

func launch(target_position: Vector3):
	var launch_direction = projectile.global_position.direction_to(target_position)
	projectile.launch(launch_direction)
