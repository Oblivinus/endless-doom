class_name AnimationHandler extends AnimationTree

@export var enemy: Enemy
@export var sprite: Sprite3D

var playback: AnimationNodeStateMachinePlayback
var root: AnimationNodeStateMachine

var current_state
var angle_axis: String = "y"

class AngleParameters:
	var frame_value: int
	var flip_h: bool
	
	func _init(init_value: int = 0, init_flip_h: bool = false) -> void:
		frame_value = init_value
		flip_h = init_flip_h

func _ready() -> void:
	playback = get("parameters/playback")
	root = tree_root as AnimationNodeStateMachine
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
	pass

func _on_attack() -> void:
	if enemy.in_pain: return
	playback.travel("attack")

func _on_died() -> void:
	var has_dmg_info = enemy.prev_dmg_info and enemy.prev_dmg_info.type == "forceful"
	if has_dmg_info and root.has_node("xdied"):
		playback.start("xdied")
	else: 
		playback.start("died")

func travel(node_name: StringName):
	playback.travel(node_name)
