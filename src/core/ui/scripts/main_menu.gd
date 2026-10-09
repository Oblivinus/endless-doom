class_name MainMenus extends CanvasLayer

@export var start_button_node: Button
@export var loadout_button_node: Button
@export var setting_button_node: Button

@export var loadout_menus: Loadout

var start_button: ButtonInteract
var loadout_button: ButtonInteract
var setting_button: ButtonInteract

class ButtonInteract:
	var button: Button
	var tween: Tween
	
	func  _init(but: Button) -> void:
		button = but
		button.mouse_entered.connect(_on_enter)
		button.mouse_exited.connect(_on_leave)
		button.pressed.connect(_on_press)
	
	func _animate_scale(target: Vector2, duration: float = 0.1) -> void:
		if tween and tween.is_valid():
			tween.kill()
		tween = button.create_tween()
		tween.tween_property(button, "scale", target, duration)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	
	func _on_enter():
		_animate_scale(Vector2(1.1, 1.1))
		#button.offset_transform_scale = Vector2(1.1, 1.1)
	
	func _on_leave():
		_animate_scale(Vector2.ONE)
		#button.offset_transform_scale = Vector2(1, 1)
	
	func _on_press():
		pass

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	loadout_menus.visible = false
	
	start_button = ButtonInteract.new(start_button_node)
	loadout_button = ButtonInteract.new(loadout_button_node)
	setting_button = ButtonInteract.new(setting_button_node)
	
	start_button.button.pressed.connect(_on_start)
	loadout_button.button.pressed.connect(_open_loadout)

func _on_start():
	if loadout_menus.is_arm_empty():
		_open_loadout()
	else:
		var loadout_on_start := loadout_menus.get_equipped_string()
		GameManager.players.set_player_loadout(loadout_on_start)
		print("Loadout : ", loadout_on_start)
		GameManager.change_scene("res://src/scenes/maps/world_dsand.tscn")

func _open_loadout():
	loadout_menus.visible = true
