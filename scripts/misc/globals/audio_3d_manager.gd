class_name Audio3DManager extends Node3D

func _ready() -> void:
	pass

func play_sound_at_position(track: AudioStream, pos_or_parent: Variant) -> AudioStreamPlayer3D:
	var audio_3d: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audio_3d.stream = track
	
	if pos_or_parent is Node3D:
		pos_or_parent.add_child(audio_3d)
	elif pos_or_parent is Vector3:
		audio_3d.global_position = pos_or_parent
		add_child(audio_3d)
	else:
		push_error("Argument 2 must be vector3 or node3d")
		return
	
	audio_3d.play(0.0)
	
	audio_3d.finished.connect(func(): 
		audio_3d.queue_free()
		)
	return audio_3d
