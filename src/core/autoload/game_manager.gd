extends Node

static var guns_cost: Dictionary[StringName, int] = GameData.get_gun_cost_dictionary()

signal on_sound(pos: Vector3)

@export var player_datas: PlayerData

var playing: bool = false
var world: World:
	get():
		var current_scene = get_tree().current_scene
		if current_scene is World:
			return current_scene
		else:
			return null

func _ready() -> void:
	player_datas.init(self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit_round") and playing:
		change_playing(false)

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
	player_datas._on_player_respawn(new_player)
	#players._on_player_respawn(new_player)

func change_playing(value: bool = true):
	if value:
		change_scene("uid://n5inmiln7lwc")
		playing = true
	else:
		change_scene("uid://b7bfro4lxkq1t")
		playing = false

func change_scene(path: String):
	get_tree().change_scene_to_file(path)
