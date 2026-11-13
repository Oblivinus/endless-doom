extends Node

const TESTING: bool = true#false

static var guns_cost: Dictionary[StringName, int] = GameData.get_gun_cost_dictionary()

signal on_sound(pos: Vector3)

@export var player_datas: PlayerData
@export var paused_screen: CanvasLayer
@export var main_menus_button: Button

var playing: bool = false
var last_wave: int = 1
var world: World:
	get():
		var current_scene = get_tree().current_scene
		if current_scene is World:
			return current_scene
		else:
			return null

var player: Player:
	set(value):
		player = value
		if value: player.on_died.connect(_on_player_died, CONNECT_ONE_SHOT)
	get:
		if not is_instance_valid(player) or player.is_queued_for_deletion():
			return null
		else:
			return player

func _ready() -> void:
	player_datas.init(self)
	paused(false, true)
	get_tree().scene_changed.connect(_scene_change)
	main_menus_button.pressed.connect(func(): Util.fakeout_input("exit_round"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused(not get_tree().paused)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit_round") and playing:
		change_playing(false)
	
	if event.is_action_pressed("clear_data"):
		print("Clearing data")
		clear_save_file()
		

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			quit_game()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			quit_game()
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			paused(true)
			save_game()
		NOTIFICATION_CRASH:
			save_game()

func _scene_change():
	if world and world.wave_manager:
		last_wave = world.wave_manager.get_current_wave()
	
	VFX.clear_line_pool()
	ObjPool.clear()

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
	if world: world.item_spawner.create_auto_pickup_area.call_deferred(new_player)

func _on_player_died():
	await  get_tree().create_timer(2).timeout
	if not playing: return
	GameManager.change_scene("uid://b7bfro4lxkq1t")
	if player: player.queue_free()

func change_playing(value: bool = true):
	if value:
		if TESTING: change_scene("uid://behldxhl6rro4") #Test Map
		else: change_scene("uid://n5inmiln7lwc")
		playing = true
	else:
		change_scene("uid://b7bfro4lxkq1t")
		playing = false
	
	if not playing:
		paused(false, true)
		player = null

func change_scene(path: String):
	get_tree().change_scene_to_file(path)

func paused(value: bool, force: bool = false) -> void:
	if not playing and not force: return
	get_tree().paused = value
	paused_screen.visible = value
	
	if value:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func save_game() -> void:
	GameData.save_player_data(player_datas.get_player_data())

func clear_save_file() -> void:
	GameData.save_player_data({})
	quit_game()

func quit_game() -> void:
	get_tree().quit()
