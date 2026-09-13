extends CharacterBody3D

@export var gun: Gun

const JUMP_VELOCITY = 4.5
const MOUSE_SENS: float = 0.25
const MAX_SPEED: float = 7.5

const ACCEL: float = 25
const DEACCEL: float = 35

var cur_speed: float = 0

#var test_cube: CSGBox3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.player = self

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Globals.isPause == false:
			Globals.isPause = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Globals.isPause = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion and not Globals.isPause:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS

func  _physics_process(delta: float) -> void:
	#print(rad_to_deg(atan2(global_basis.z.x, global_basis.z.z)))
	if Globals.isPause: return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var move_dir: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if move_dir:
		cur_speed = move_toward(cur_speed, MAX_SPEED, ACCEL * delta)
		velocity.x = cur_speed * move_dir.x
		velocity.z = cur_speed * move_dir.z
	else:
		cur_speed = move_toward(cur_speed, 0, DEACCEL * delta)
		velocity.x = move_toward(velocity.x, 0, DEACCEL * delta)
		velocity.z = move_toward(velocity.z, 0, DEACCEL * delta)
		
	
	move_and_slide()
	Globals.player_pos = global_position
