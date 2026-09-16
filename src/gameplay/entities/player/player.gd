class_name Player extends Humanoid

const MOUSE_SENS = 0.25

@onready var colorrect: ColorRect = $Head/Camera3D/CanvasLayer/Control/ColorRect

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	on_hurt.connect(_on_hurt)
	Globals.player = self

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS


func _physics_process(delta: float) -> void:
	super(delta)
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var new_move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if new_move_dir:
		move_to_direction(new_move_dir)
	else:
		stop_move()

func _on_hurt(dmg: float):
	var fade_in = create_tween()
	colorrect.modulate.a = 0.25
	await get_tree().create_timer(0.15).timeout
	colorrect.modulate.a = 0.0
