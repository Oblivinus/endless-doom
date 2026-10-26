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
var blend_data: Dictionary[Vector2, AngleParameter]
var facing_reference: Node3D

var _last_param: AngleParameter
var _last_node: StringName

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
	
	if anim_tree:
		playback = anim_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if Globals.player == null or facing_reference == null or angle_params.is_empty(): return

	var dir: Vector2 = get_local_direction(Globals.player.global_position)
	if dir == Vector2.ZERO: return
	var angle_param := _get_nearest(dir)

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

func _get_nearest(input: Vector2) -> AngleParameter:
	var best: AngleParameter = angle_params[0]
	var best_dot := -INF
	for p in angle_params:
		var d := input.dot(p.angle_vect.normalized())
		if d > best_dot:
			best_dot = d
			best = p
	return best

func get_local_direction(target_pos: Vector3) -> Vector2:
	var d := target_pos - facing_reference.global_position
	var flat := Vector2(d.x, d.z)
	if flat.is_zero_approx(): return Vector2.ZERO
	return flat.rotated(facing_reference.global_rotation.y)

func get_nearest_blend_data(input: Vector2) -> AngleParameter:
	var nearest_dist := INF
	var result: AngleParameter = blend_data[Vector2(0, -1)]
	
	for key in blend_data.keys():
		var dist = key.distance_squared_to(input)
		if dist < nearest_dist:
			nearest_dist = dist
			result = blend_data[key]
	return result
