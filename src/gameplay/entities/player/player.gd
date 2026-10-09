class_name Player extends Humanoid

const MOUSE_SENS = 0.25

@export var arsenal: Arsenal
@export var gun: Gun
@export var camera: Camera3D

@export var player_stat_ui: PlayerStatUi

@export_category("Stats")
@export var armor_absorption: float = 0.35
@export var armor: float = 100:
	set(value):
		armor = clamp(value, 0, max_health)
		property_changed.emit("armor", armor)

var colorrect: ColorRect

var sway_speed: float = 2.5
var sway_amount: float = 0.18
var time_passed: float = 0.0
var base_y := 0.0
const TAU_F := TAU

signal on_kill(enemy: Enemy)

func _ready() -> void:
	super()
	
	base_y = camera.position.y
	health = 100.0
	colorrect = player_stat_ui.screen_modulate
	
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
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS

func _process(_delta: float) -> void:
	if Input.is_action_pressed("Attack"):
		arsenal.shoot_current()

func _physics_process(delta: float) -> void:
	super(delta)
	
	cam_sway(delta)
	
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

func hurt(damage: float, ..._args: Array) -> void:
	if is_dead: return
	if armor > 0:
		var health_damage = damage * (1 - armor_absorption)
		armor -= damage * armor_absorption
		health -= health_damage
		on_hurt.emit(health_damage)
	else:
		super(damage)

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
