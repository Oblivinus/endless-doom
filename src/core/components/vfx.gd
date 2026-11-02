class_name VFX extends Node3D

var _emitters: Array[GPUParticles3D] = []
var _anim: AnimationPlayer
var _audio: Node
var _one_shot: bool = false
var _content: Node3D

var this_pos: Vector3

static var bullet_line_scene: PackedScene = preload("uid://cs8fnp8d00ruf")
static var _line_pool: Array[Node3D] = []
static var _pool: Dictionary[StringName, Array]

#region LINE POOL - Why? im to lazy to merge it to normal pool
static func _get_line() -> Node3D:
	while not _line_pool.is_empty():
		var line: Node3D = _line_pool.pop_back()
		if is_instance_valid(line):
			return line
	var new_line: Node3D = bullet_line_scene.instantiate()
	new_line.visible = false
	GameManager.world.add_child(new_line)
	return new_line

static func release_line(line: Node3D) -> void:
	line.visible = false
	line.set_process(false)
	line.reparent(null)
	_line_pool.append(line)

static func create_bullet_line(from: Vector3, to: Vector3) -> Node3D:
	var line := _get_line()
	line.fire(from, to)
	return line

static func create_bullet_line_direction(from: Vector3, to: Vector3, length: float) -> Node3D:
	return create_bullet_line(from, from + from.direction_to(to) * length)

static func clear_line_pool() -> void:
	_line_pool.clear()
#endregion

func  _init(vfx_name: String, pos: Vector3 = Vector3.ZERO) -> void:
	if vfx_name != "":
		_load(vfx_name)
	
	this_pos = pos

func _ready() -> void:
	global_position = this_pos

func _load(vfx_name: String) -> void:
	var path := "res://assets/vfx/%s.tscn" % vfx_name
	if not ResourceLoader.exists(path):
		push_error("VFX '%s' not found at %s" % [vfx_name, path])
		return
	var scene: PackedScene = load(path)
	_content = scene.instantiate()
	add_child(_content)
	_collect(_content)



func _collect(node: Node) -> void:
	for child in node.get_children():
		if child is GPUParticles3D or child is CPUParticles3D:
			_emitters.append(child)
			if child.one_shot:
				_one_shot = true
		elif child is AnimationPlayer:
			_anim = child
		elif child is AudioStreamPlayer3D or child is AudioStreamPlayer:
			_audio = child
		_collect(child)



func play() -> void:
	for e in _emitters:
		e.emitting = true
	if _anim and _anim.get_animation_list().size() > 0:
		_anim.play("play")
	if _audio:
		_audio.play()
	if _one_shot:
		_auto_free()

func restart() -> void:
	for e in _emitters:
		e.restart()
		e.emitting = true
	if _anim:
		_anim.seek(0.0, true)
		if _anim.get_animation_list().size() > 0:
			_anim.play("play")
	if _audio:
		_audio.stop()
		_audio.play()
	if _one_shot:
		_auto_free()


func stop() -> void:
	for e in _emitters:
		e.emitting = false
	if _anim:
		_anim.stop()
	if _audio:
		_audio.stop()



func _auto_free() -> void:
	var max_time := 0.0
	for e in _emitters:
		max_time = max(max_time, e.lifetime)
	if _anim and _anim.current_animation != "":
		max_time = max(max_time, _anim.current_animation_length)
	if not is_inside_tree():
		await ready
	await get_tree().create_timer(max_time + 0.1).timeout
	if is_instance_valid(self):
		queue_free()
