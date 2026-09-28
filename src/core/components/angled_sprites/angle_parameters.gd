class_name AngleParameter extends Resource

enum ANGLE {
	F,
	F_L,
	L,
	B_L,
	F_R,
	R,
	B_R,
	B,
}

static var angle_vect_dict: Dictionary[ANGLE, Vector2] = {
	ANGLE.F: Vector2(0, -1),
	ANGLE.F_L: Vector2(-0.5, -0.5),
	ANGLE.L: Vector2(-1, 0),
	ANGLE.B_L: Vector2(-0.5, 0.5),
	
	ANGLE.F_R: Vector2(0.5, -0.5),
	ANGLE.R: Vector2(1, 0),
	ANGLE.B_R: Vector2(0.5, 0.5),
	ANGLE.B: Vector2(0, 1),
}

@export var ANGLE_STRING: String = "F" ##THIS IS READ ONLY
@export var angle_vect: Vector2 = Vector2(0, -1)
@export var value: int = 0
@export var flip: bool = false

func _init(new_angle: ANGLE = ANGLE.F, frame_value: int = 0, flipped: bool = false) -> void:
	ANGLE_STRING = get_angle_string(new_angle)
	angle_vect = angle_vect_dict[new_angle]
	value = frame_value
	flip = flipped

func get_angle_string(angle_enum):
	return ANGLE.find_key(angle_enum)
