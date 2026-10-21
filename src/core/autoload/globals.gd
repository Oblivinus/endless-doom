extends Node

var isPause = false

var player_pos: Vector3
var player: Player:
	set(value):
		player = value
		if value: player.on_died.connect(_on_player_died, CONNECT_ONE_SHOT)
	get:
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			return null
		else:
			return player
		
var world: Node3D:
	get():
		return get_tree().current_scene

signal detected_sound(pos: Vector3, type: String)

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
	GameManager.change_scene("uid://b7bfro4lxkq1t")
	player.queue_free()
	player = null
	
	#var new_player: Player = Ref.player.instantiate() as Player
	#new_player.transform = prev_tranform
	#prev_parent.add_child(new_player)
	#player = new_player
