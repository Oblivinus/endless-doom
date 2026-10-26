class_name ProjectileLauncher extends RefCounted

static var _projectile_pool: Dictionary[StringName, Array] = {}

var projectile: Projectile

var on_hit: Array[Humanoid]

static func return_to_pool(p: Projectile) -> void:
	if not is_instance_valid(p): return
	_projectile_pool.get_or_add(p.pool_name, []).append(p)

static func pull_from_pool(projectile_name: StringName) -> Projectile:
	var pool: Array = _projectile_pool.get_or_add(projectile_name, [])
	
	# Skip any that were freed (e.g. on scene change)
	var p: Projectile
	
	while not pool.is_empty():
		p = pool.pop_back()
		if is_instance_valid(p): return p
	
	p = Ref.projectiles[projectile_name].instantiate()
	p.pool_name = projectile_name
	return p

static func clear_pool() -> void:
	for pool in _projectile_pool.values():
		for p in pool:
			if is_instance_valid(p): p.queue_free()
	_projectile_pool.clear()

func _init(projectile_name: String, origin: Vector3) -> void:
	var key := StringName(projectile_name.to_lower())
	if not Ref.projectiles.has(projectile_name.to_lower()): 
		print("Projectile \"%s\" does not exist")
		return
	
	projectile = pull_from_pool(key)
	Globals.world.add_child(projectile)
	projectile.activate(origin)

func launch(target_position: Vector3):
	var launch_direction = projectile.global_position.direction_to(target_position)
	projectile.launch(launch_direction)
