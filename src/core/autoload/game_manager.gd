extends Node

signal on_sound(pos: Vector3)

var playing: bool = false
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
	var d_point: int = 0:
		set(value):
			d_point = clamp(value, 0, 999_999)
	
	var owned_gun: Array[StringName] = []
	
	func _init(parent) -> void:
		game_manager = parent
	
	func _on_player_respawn(new_player: Player):
		player = new_player
		player.on_kill.connect(_on_enemy_kill)
	
	func _on_enemy_kill(enemy: Enemy) -> void:
		var d_point_earned = randi_range(enemy.d_point_drop[0], enemy.d_point_drop[1])
		add_d_coint(d_point_earned)
	
	func get_player() -> Player:
		return player
	
	func get_player_ammo_used() -> Array[Enums.GUN_TYPES]:
		var arsenal: Arsenal = player.arsenal
		return arsenal.get_used_ammo()
	
	func get_player_arms() -> Array[StringName]:
		return player_loadout
	
	func set_player_arms(value: Array[StringName]) -> void:
		player_loadout = value
	
	func add_d_coint(value: int) -> void:
		d_point += value
	
	func buy_gun(gun_name: StringName) -> bool:
		if not Ref.guns_cost.has(gun_name): return false
		var cost: int = Ref.guns_cost[gun_name]
		
		if d_point >= cost:
			d_point -= cost
			owned_gun.append(gun_name)
			
		return true
	
	func get_owned_guns() -> Array[StringName]:
		return owned_gun

func _ready() -> void:
	players = Players.new(self)

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
	players._on_player_respawn(new_player)

func change_playing(value: bool = true):
	if value:
		change_scene("uid://n5inmiln7lwc")
		playing = true
	else:
		change_scene("uid://b7bfro4lxkq1t")
		playing = false

func change_scene(path: String):
	get_tree().change_scene_to_file(path)
