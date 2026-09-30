class_name StateMachine extends Node

@export var starting_state: State
@export var current_state: State
var states: Dictionary[String, State] = {}

func  _ready() -> void:
	for child: State in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_state_transition)

func _process(delta: float) -> void:
	if current_state:
		current_state.process_frame(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process_physics(delta)

func _input(input: InputEvent) -> void:
	if current_state:
		current_state.process_input(input)

func _on_state_transition(state: State, new_state_name: String):
	if state != current_state: return
		
	var new_state: State = get_state(new_state_name)
	if !new_state: return
	
	change_state(new_state)



func init(parent: Node) -> void:
	for state: State in get_children():
		state.parent = parent
		state.machine = self
		state._state_machine_ready()
	change_state(starting_state)

func change_state(new_state: State):
	if current_state:
		current_state.exit()
		
	current_state = new_state
	current_state.enter()
	
func change_state_name(state_name: String):
	var new_state: State = get_state(state_name)
	if !new_state: return
	
	change_state(new_state)
	

func get_state(state_name: String) -> State:
	return states[state_name.to_lower()]
