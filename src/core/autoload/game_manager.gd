extends Node

signal on_sound(pos: Vector3)

func play_hearable_sound(audio_name: String, pos_or_node3: Variant) -> Audio3D:
	var audio = Audio3D.new(audio_name, pos_or_node3)
	var pos: Vector3
	
	if pos_or_node3 is Node3D:
		pos = pos_or_node3.global_position
	elif pos is Vector3:
		pos = pos_or_node3
	else:
		return null
	
	on_sound.emit(pos)
	return audio

func change_scene(path: String):
	get_tree().change_scene_to_file(path)
