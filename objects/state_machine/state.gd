class_name State extends Node

@export var parent: Enemy
@export var machine: StateMachine
signal transitioned(self_state: State, new_state: String)

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func process_physics(delta: float):
	return null

func process_frame(delta: float):
	return  null
	
func process_input(input: InputEvent):
	return null
