extends Node

var isPause = false
var player_pos: Vector3
var player: CharacterBody3D
var world: Node3D

func _ready() -> void:
	world = get_tree().current_scene
