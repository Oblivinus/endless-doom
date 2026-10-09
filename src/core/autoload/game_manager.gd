extends Node

signal on_sound(pos: Vector3)

var players: Players
var world: World:
	get():
		var current_scene = get_tree().current_scene
		if current_scene is World:
			return current_scene
		else:
			return null

class Players:
	var player: Player
	var player_loadout: Array[StringName]
	var game_manager: GameManager
	
	func _init(parent) -> void:
		game_manager = parent
	
	func _on_player_respawn(new_player: Player):
		player = new_player
	
	func get_player() -> Player:
		return player
	
	func get_player_ammo_used() -> Array[Enums.GUN_TYPES]:
		var arsenal: Arsenal = player.arsenal
		return arsenal.get_used_ammo()
	
	func get_player_loadout() -> Array[StringName]:
		return player_loadout
	
	func set_player_loadout(value: Array[StringName]) -> void:
		player_loadout = value

func _ready() -> void:
	players = Players.new(self)

func play_hearable_sound(audio_name: String, pos_or_node3: Variant) -> Audio3D:
	var audio = Audio3D.new(audio_name, pos_or_node3)
	var pos: Vector3
	
	if pos_or_node3 is Node3D:
		pos = pos_or_node3.global_position
	elif pos is Vector3:
		pos = pos_or_node3
	else:
		return null
	
	on_sound.emit(pos)
	return audio

func player_respawn(new_player: Player):
	players._on_player_respawn(new_player)

func change_scene(path: String):
	get_tree().change_scene_to_file(path)
