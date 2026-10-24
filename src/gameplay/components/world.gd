class_name World extends Node3D

signal enemy_died(enemy: Enemy, last_pos: Vector3)

class ItemSpawner:
	var parent: World
	
	var item_dict: Dictionary[String, Callable] = {
		"healthpotion": HealthPotion.create,
		"armorpoint": ArmorPoint.create,
		"ammos": Ammos.create,
	}
	
	func _init(new_parent: World) -> void:
		parent = new_parent
	
	func spawn(item_name: String, pos: Vector3 = Vector3.ZERO, offset: Vector3 = Vector3.ZERO) -> void:
		if not item_dict.has(item_name.to_lower()): return
		var launch_vect: Vector3 = Vector3(0, 5, -5).normalized()  * 20
		var rand_angle: int = randi_range(-180, 180)
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
		item.amount = [2, 6].pick_random()
		return item
	
	func delay_pick(item: Item) -> void:
		item.pickable = false
		await parent.get_tree().create_timer(0.15).timeout
		item.pickable = true

var item_spawner: ItemSpawner

func _ready() -> void:
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
