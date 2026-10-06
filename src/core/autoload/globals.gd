extends Node

var isPause = false

var player_pos: Vector3
var player: Player:
	set(value):
		player = value
		player.on_died.connect(_on_player_died, CONNECT_ONE_SHOT)
	get:
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			return null
		else:
			return player
		
var world: Node3D
var item_spawner: ItemSpawner

signal enemy_died(enemy: Enemy, last_pos: Vector3)
signal detected_sound(pos: Vector3, type: String)

class ItemSpawner:
	var parent: Globals
	
	var item_dict: Dictionary[String, Callable] = {
		"healthpotion": HealthPotion.create,
		"armorpoint": ArmorPoint.create,
		"ammos": Ammos.create,
	}
	
	func _init(new_parent: Globals) -> void:
		parent = new_parent
	
	func spawn(item_name: String, pos: Vector3 = Vector3.ZERO) -> void:
		if not item_dict.has(item_name.to_lower()): return
		var launch_vect: Vector3 = Vector3(0, 5, -5).normalized()  * 20
		var rand_angle: int = randi_range(-180, 180)
		launch_vect = launch_vect.rotated(Vector3.UP, deg_to_rad(rand_angle))
		
		var item: Item
		if item_name.to_lower() == "ammos":
			item = item_dict[item_name].call() as Ammos
			item.ammo_type = Enums.GUN_TYPES.get(Enums.get_guns_type().pick_random())
			item.amount = [2, 6].pick_random()
		else:
			item = item_dict[item_name].call()
		item.position =  pos
		item.expired = true
		parent.get_items_node().add_child(item)
		item.apply_central_impulse(launch_vect)
		
func _ready() -> void:
	item_spawner = ItemSpawner.new(self)
	world = get_tree().current_scene

func any_enemy_died(enemy: Enemy, last_pos: Vector3):
	var chance: float = randi_range(1, 2)
	enemy_died.emit(enemy, last_pos)
	
	for i: int in range(chance):
		item_spawner.spawn(item_spawner.item_dict.keys().pick_random(), last_pos)

func get_enemies_node() -> Node:
	if not world: return null
	return world.get_node("Enemies")

func get_items_node() -> Node:
	if not world: return null
	return world.get_node("Items")

func trigger_sound_detection(pos: Vector3, type: String = "generic"):
	detected_sound.emit(pos, type)

func _on_player_died():
	var prev_parent = player.get_parent()
	var prev_tranform = player.transform
	
	await  get_tree().create_timer(2).timeout
	player.queue_free()
	
	var new_player: Player = Ref.player.instantiate() as Player
	new_player.transform = prev_tranform
	prev_parent.add_child(new_player)
	player = new_player
