class_name World extends Node3D

@export var wave_manager: WaveManager
signal enemy_died(enemy: Enemy, last_pos: Vector3)

class ItemSpawner:
	const AUTO_PICKUP_RADIUS = 10
	var parent: World
	
	var item_dict: Dictionary[StringName, Callable] = {
		&"healthpotion": HealthPotion.create,
		&"armorpoint": ArmorPoint.create,
		&"ammos": Ammos.create,
	}
	
	var item_spawn_weight: Dictionary[StringName, int] = {
		&"healthpotion": 30,
		&"armorpoint": 60,
		&"ammos": 100,
	}
	
	var ammo_base_amount: Dictionary[Enums.GUN_TYPES, Array] = {
		Enums.GUN_TYPES.BULLET: [3, 12],
		Enums.GUN_TYPES.SHELL: [1, 4],
		Enums.GUN_TYPES.ROCKET: [1, 4],
		Enums.GUN_TYPES.CELL: [5, 20],
	}
	
	var item_to_spawn_roller: WeightedRoll
	
	func _init(new_parent: World) -> void:
		parent = new_parent
		item_to_spawn_roller = WeightedRoll.new(item_spawn_weight)
	
	func _auto_pickup(item: Item, follow_target: Node3D, pick_up: bool = true) -> void:
		if not item is Item: return
		if pick_up: item.follow(follow_target)
		else: item.stop_follow()
	
	func spawn_random_batch(amount: int, pos: Vector3 = Vector3.ZERO, offset: Vector3 = Vector3.ZERO):
		for i in range(amount):
			var item_name: StringName = item_to_spawn_roller.roll() as StringName
			spawn(item_name, pos, offset)
		
	
	func spawn(item_name: String, pos: Vector3 = Vector3.ZERO, offset: Vector3 = Vector3.ZERO) -> void:
		if not item_dict.has(item_name.to_lower()): return
		var launch_vect: Vector3 = Vector3(0, 5, -5).normalized()  * 20
		var rand_angle: int = randi_range(-180, 180)
		launch_vect *= range(10, 16, 1).pick_random() / 10
		launch_vect = launch_vect.rotated(Vector3.UP, deg_to_rad(rand_angle))
		
		var item: Item
		if item_name.to_lower() == "ammos":
			item = spawn_ammo()
		else:
			item = item_dict[item_name].call()
		
		item.position =  pos + offset
		item.expired = true
		parent.get_items_node().add_child(item)
		item.apply_central_impulse(launch_vect)
		delay_pick(item)
	
	func spawn_ammo() -> Ammos:
		if not GameManager.player_datas.get_player() or GameManager.player_datas.get_player_ammo_used().is_empty(): return
		
		var used_ammo: Array[Enums.GUN_TYPES] = GameManager.player_datas.get_player_ammo_used()
		var item: Item
		item = item_dict["ammos"].call() as Ammos
		item.ammo_type = used_ammo.pick_random()
		
		var amount_pool: Array = ammo_base_amount.get(item.ammo_type, [1, 3])
		var rand_amount: int = range(amount_pool[0], amount_pool[1] + amount_pool[0], amount_pool[0] ).pick_random()
		item.amount = rand_amount
		return item
	
	func delay_pick(item: Item) -> void:
		item.pickable = false
		await parent.get_tree().create_timer(3, false).timeout
		item.pickable = true
	
	func create_auto_pickup_area(player: Player) -> void:
		var shape: SphereShape3D = SphereShape3D.new()
		shape.radius = AUTO_PICKUP_RADIUS
		
		var area: Area3D = Util.create_area_3d(player, shape, [7])
		area.body_entered.connect( func(item: Item): _auto_pickup(item, player) )
		area.body_exited.connect( func(item: Item): _auto_pickup(item, player, false) )
		

var item_spawner: ItemSpawner

func _init() -> void:
	item_spawner = ItemSpawner.new(self)

func _any_enemy_died(enemy: Enemy, last_pos: Vector3):
	var chance: float = randi_range(1, 2)
	enemy_died.emit(enemy, last_pos)
	
	for i: int in range(chance):
		spawn_item(item_spawner.item_dict.keys().pick_random(), last_pos)

func spawn_item(item_name: StringName, last_pos: Vector3 = Vector3.ZERO):
	item_spawner.spawn(item_name, last_pos)

func get_items_node() -> Node:
	return $Items
