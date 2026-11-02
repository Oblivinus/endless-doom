class_name Enums extends Node

enum IDLE_STATUS {
	WANDERING,
	ALERTED
}

enum GUN_TYPES {
	NONE,
	BULLET,
	SHELL,
	ROCKET,
	CELL,
}

func get_guns_type() -> Array:
	return GUN_TYPES.keys()
