extends Node

enum IDLE_STATUS {
	WANDERING,
	ALERTED
}

enum GUN_TYPES {
	BULLET,
	SHELL,
	ROCKET
}

func get_guns_type() -> Array:
	return GUN_TYPES.keys()
