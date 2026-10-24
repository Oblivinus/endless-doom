class_name Player extends Humanoid

const MOUSE_SENS = 0.25

@export var arsenal: Arsenal
@export var gun: Gun
@export var camera: Camera3D

@export var player_stat_ui: PlayerStatUi
var player_camera: Camera

@export_category("Stats")
@export var armor_absorption: float = 0.35:
	set(value):
		armor_absorption = clampf(value, 0, 1)
@export var armor: float = 100:
	set(value):
		armor = clamp(value, 0, max_health)
		property_changed.emit("armor", armor)
@export var damage_boost: float = 1.0
@export var drop_chance_multiplier: float = 1.0

var colorrect: ColorRect
var sway_speed: float = 2.5
var sway_amount: float = 0.18
var time_passed: float = 0.0
var base_y := 0.0
const TAU_F := TAU

var movement_disabled: bool = false
var invincible: bool = false
var camera_disable: bool = false

signal on_kill(enemy: Enemy)

func _ready() -> void:
	super()
	
	health = 100.0
	colorrect = player_stat_ui.screen_modulate
	player_camera = Camera.new(self)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	on_hurt.connect(_on_hurt)
	on_died.connect(_on_died)
	property_changed.connect(_on_property_changed)
	Globals.player = self
	
	_on_property_changed("health", health)
	GameManager.player_respawn(self)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not camera_disable:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Attack"):
		arsenal.shoot_current()

func _physics_process(delta: float) -> void:
	super(delta)
	
	player_camera._process(delta)
	
	if movement_disabled: 
		stop_move() 
		return
	
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var new_move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if new_move_dir:
		move_to_direction(new_move_dir)
	else:
		stop_move()
	arsenal.is_moving = is_moving

func _on_property_changed(property_name, new_value):
	pass

func _on_hurt(_dmg: float):
	pass
	
func _on_died():
	pass

func look_at_pos(vec3: Vector3) -> void:
	var flat_target := Vector3(vec3.x, global_position.y, vec3.z)
	if flat_target.is_equal_approx(global_position): return
	look_at(flat_target, Vector3.UP)

func disable_movement(value: bool = true) -> void:
	movement_disabled = value
	pass

func hurt(damage: float, ..._args: Array) -> void:
	if invincible: return
	if is_dead: return
	if armor > 0:
		var armor_damage = damage * armor_absorption
		var preclamp_armor_health = armor - armor_damage
		var health_damage = damage * (1 - armor_absorption)
		
		if preclamp_armor_health < 0:
			health_damage -= preclamp_armor_health
		
		armor = preclamp_armor_health
		health -= health_damage
		on_hurt.emit(health_damage)
	else:
		super(damage)
	
	player_camera.shake(0.1)

var sway_reset_deadzone: float
func cam_sway(delta):
	if is_moving: 
		sway_reset_deadzone = 0.0
		time_passed= fmod(time_passed + delta * sway_speed, TAU_F)
		camera.position.y = base_y + sin(time_passed * sway_speed) * sway_amount
	else:
		sway_reset_deadzone += delta
		if sway_reset_deadzone >= 0.15:
			camera.position.y = move_toward(camera.position.y, base_y, delta * sway_speed)
			time_passed = 0

class Camera:
	
	var player: Player
	var camera_node: Camera3D
	
	#region SWAY
	var sway_reset_deadzone: float
	var sway_speed: float = 2.5
	var sway_amount: float = 0.18
	var time_passed: float = 0.0
	var base_y := 0.0
	const TAU_F := TAU
	#endregion
	
	#region SHAKE
	var shake_fade: float = 10.0
	var shake_strength: float = 0.0
	#endregion
	
	func _init(i_player: Player) -> void:
		player = i_player
		camera_node = player.camera
		base_y = camera_node.position.y
	
	func _process(delta: float) -> void:
		_cam_sway(delta)
		_cam_shake_process(delta)
	
	func _cam_shake_process(delta: float) -> void:
		if shake_strength <= 0.0:
			return
		
		camera_node.h_offset = randf_range(-shake_strength, shake_strength)
		camera_node.v_offset = randf_range(-shake_strength, shake_strength)
		shake_strength = lerpf(shake_strength, 0.0, delta * shake_fade)
		
		if shake_strength < 0.001:
			shake_strength = 0.0
			camera_node.h_offset = 0.0
			camera_node.v_offset = 0.0
	
	func _cam_sway(delta):
		if player.is_moving: 
			sway_reset_deadzone = 0.0
			time_passed= fmod(time_passed + delta * sway_speed, TAU_F)
			camera_node.position.y = base_y + sin(time_passed * sway_speed) * sway_amount
		else:
			sway_reset_deadzone += delta
			if sway_reset_deadzone >= 0.15:
				camera_node.position.y = move_toward(camera_node.position.y, base_y, delta * sway_speed)
				time_passed = 0
	
	func shake(strength: float = 0.2) -> void:
		shake_strength = maxf(shake_strength, strength)
