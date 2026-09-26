class_name Audio3D extends AudioStreamPlayer3D

const SUPPORTED_EXTENSIONS := ["ogg", "wav", "mp3"]

var pos: Vector3

func _init(audio_name: String, pos_or_node3d: Variant) -> void:
	var path := _find_audio_path(audio_name)
	if path.is_empty():
		print("Sound '%s' not found in res://assets/sounds/ (tried: %s)" % [audio_name, ", ".join(SUPPORTED_EXTENSIONS)])
		push_error("Sound '%s' not found in res://assets/sounds/ (tried: %s)" % [audio_name, ", ".join(SUPPORTED_EXTENSIONS)])
		return
	
	var loaded_stream = load(path)
	if not (loaded_stream is AudioStream):
		push_error("Resource at %s is not a valid AudioStream" % path)
		return
	
	stream = loaded_stream
	if pos_or_node3d is Node3D:
		pos_or_node3d.add_child(self)
	elif pos_or_node3d is Vector3:
		Globals.world.add_child(self)
		pos = pos_or_node3d
	else:
		push_error("Audio3D parameter 2 is not node3d or vector3")
		queue_free()
		return
	finished.connect(queue_free)

func _ready() -> void:
	global_position = pos

func _find_audio_path(audio_name: String) -> String:
	for ext in SUPPORTED_EXTENSIONS:
		var path := "res://assets/sounds/%s.%s" % [audio_name, ext]
		if ResourceLoader.exists(path):
			return path
	return ""
