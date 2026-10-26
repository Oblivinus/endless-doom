@tool
class_name AngledSprite3D extends Sprite3D

@export var anim_tree: AnimationTree

@export_tool_button("Fill Default Parameters") var fill: Callable = _default_value
@export var angle_params: Array[AngleParameter] = []

@export var anim_angle_axis_dict: Dictionary[String, String] = {
	"idle": "y",
	"walk": "y",
	"attack": "y",
	"hurt": "x",
	"died": "n/a",
	"xdied": "n/a"
}

var playback: AnimationNodeStateMachinePlayback
var facing_reference: Node3D

var _sector_params: Array[AngleParameter] = []
var _base_angle: float = 0.0
var _step: float = TAU / 8.0

func _default_value() -> void:
	angle_params = _default_table()
	notify_property_list_changed()

func _default_table() -> Array[AngleParameter]:
	return [
		AngleParameter.new(AngleParameter.ANGLE.F, 0),
		AngleParameter.new(AngleParameter.ANGLE.F_L, 1),
		AngleParameter.new(AngleParameter.ANGLE.L, 2),
		AngleParameter.new(AngleParameter.ANGLE.B_L, 3),
		AngleParameter.new(AngleParameter.ANGLE.B, 4),

		AngleParameter.new(AngleParameter.ANGLE.F_R, 1, true),
		AngleParameter.new(AngleParameter.ANGLE.R, 2, true),
		AngleParameter.new(AngleParameter.ANGLE.B_R, 3, true)
	] as Array[AngleParameter]

func _ready() -> void:
	if Engine.is_editor_hint(): return

	process_priority = 100

	if facing_reference == null:
		facing_reference = get_parent() as Node3D

	if angle_params.is_empty():
		angle_params = _default_table()

	_build_sector_table()

	if anim_tree:
		playback = anim_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

func _build_sector_table() -> void:
	var sorted := angle_params.duplicate()
	sorted.sort_custom(func(a: AngleParameter, b: AngleParameter) -> bool:
		return fposmod(a.angle_vect.angle(), TAU) < fposmod(b.angle_vect.angle(), TAU))
	_sector_params.assign(sorted)

	var n := _sector_params.size()
	_step = TAU / n
	_base_angle = fposmod(_sector_params[0].angle_vect.angle(), TAU)

	for i in n:
		var expected := fposmod(_base_angle + i * _step, TAU)
		var actual := fposmod(_sector_params[i].angle_vect.angle(), TAU)
		if absf(angle_difference(expected, actual)) > 0.05:
			push_warning("AngledSprite3D: angle_params are not evenly spaced, sector lookup will be inaccurate.")
			break

func _get_sector(dir: Vector2) -> AngleParameter:
	var a := fposmod(dir.angle() - _base_angle, TAU)
	var idx := int(roundf(a / _step)) % _sector_params.size()
	return _sector_params[idx]

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if Globals.player == null or facing_reference == null or _sector_params.is_empty(): return

	var dir: Vector2 = get_local_direction(Globals.player.global_position)
	if dir == Vector2.ZERO: return
	var angle_param := _get_sector(dir)

	var current_node: StringName
	if anim_tree and playback:
		current_node = playback.get_current_node()

	var anim_axis: StringName = "x"
	if current_node and anim_angle_axis_dict.has(current_node):
		anim_axis = anim_angle_axis_dict[current_node]

	if anim_axis == "n/a": return

	var fc := frame_coords
	if anim_axis == "y":
		fc.y = angle_param.value
	else:
		fc.x = angle_param.value

	if fc != frame_coords:
		frame_coords = fc
	if flip_h != angle_param.flip:
		flip_h = angle_param.flip

func get_local_direction(target_pos: Vector3) -> Vector2:
	var local_pos := facing_reference.to_local(target_pos)
	return Vector2(local_pos.x, local_pos.z)
