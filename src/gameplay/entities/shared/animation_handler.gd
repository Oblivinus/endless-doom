class_name AnimationHandler extends AnimationTree

@export var enemy: Enemy
@export var sprite: Sprite3D

var playback: AnimationNodeStateMachinePlayback

var blend_data: Dictionary[Vector2, AngleParameters] = {
	Vector2(0, -1):  AngleParameters.new(0), #f
	Vector2(-0.5, -0.5): AngleParameters.new(1), #f l
	Vector2(-1, 0): AngleParameters.new(2), 	#l
	Vector2(-0.5, 0.5): AngleParameters.new(3), #b l
	Vector2(0, 1): AngleParameters.new(4), #b
	Vector2(0.5, 0.5): AngleParameters.new(5), #f r
	Vector2(1, 0): AngleParameters.new(6), #r
	Vector2(0.5, -0.5):  AngleParameters.new(7), 	#b r
}

var current_state
var angle_axis: String = "y"
var anim_angle_axis_dict: Dictionary[String, String] = {
	"idle": "y",
	"walk": "y",
	"attack": "y",
	"hurt": "x",
	"died": "nan",
}

class AngleParameters:
	var frame_value: int
	var flip_h: bool
	
	func _init(init_value: int = 0, init_flip_h: bool = false) -> void:
		frame_value = init_value
		flip_h = init_flip_h

func _ready() -> void:
	playback = get("parameters/playback")
	active = true
	
	var sm: AnimationNodeStateMachine = tree_root as AnimationNodeStateMachine
	for i in sm.get_transition_count():
		if sm.get_transition_from(i) == "hurt" and sm.get_transition_to(i) == "idle":
			var transition := sm.get_transition(i)
			transition.advance_expression = "!in_pain"
			
		if sm.get_transition_from(i) == "idle" and sm.get_transition_to(i) == "walk":
			var transition := sm.get_transition(i)
			transition.advance_expression = "is_moving"
		
		if sm.get_transition_from(i) == "walk" and sm.get_transition_to(i) == "idle":
			var transition := sm.get_transition(i)
			transition.advance_expression = "!is_moving"
	
	enemy.on_attack.connect(_on_attack)
	enemy.on_died.connect(_on_died)

func _process(_delta: float) -> void:
	current_state = playback.get_current_node()
	var player_dir = enemy.get_local_direction_to(Globals.player.global_position)
	var blend_pos = Vector2(player_dir.x, player_dir.z)
	
	var angle_params: AngleParameters = get_nearest_blend_data(blend_pos)
	if anim_angle_axis_dict[current_state] == "y":
		sprite.frame_coords.y = angle_params.frame_value
	elif anim_angle_axis_dict[current_state] == "x":
		sprite.frame_coords.x = angle_params.frame_value
		
	sprite.flip_h = angle_params.flip_h

func _on_attack() -> void:
	if enemy.in_pain: return
	playback.travel("attack")

func _on_died() -> void:
	playback.start("died")

func get_nearest_blend_data(input: Vector2) -> AngleParameters:
	var nearest_dist := INF
	var result: AngleParameters = blend_data[Vector2(0, -1)]
	
	for key in blend_data.keys():
		var dist = key.distance_squared_to(input)
		if dist < nearest_dist:
			nearest_dist = dist
			result = blend_data[key]
	return result

func travel(node_name: StringName):
	playback.travel(node_name)
