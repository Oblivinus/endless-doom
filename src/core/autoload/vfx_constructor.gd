class_name VfxConstructor extends Node3D

static var VFX_PATH: String = "res://assets/vfx/"

static var vfx_cache: Dictionary[StringName, PackedScene] = {}

var _emitters: Array = []
var _anim: AnimationPlayer

var pool_name: StringName
var max_duration: float = 0.0
var one_shot: bool = false

func _init(vfx_name: StringName) -> void:
	var content_scene: PackedScene = _load(vfx_name)
	var scene: Node3D = content_scene.instantiate()
	
	_collect(scene)
	add_child(scene)

func play_at(node_or_vec3: Variant):
	if node_or_vec3 is Vector3: 
		if GameManager.world: GameManager.world.add_child(self)
		global_position = node_or_vec3
	elif node_or_vec3 is Node3D:
		node_or_vec3.add_child(self)
	
	for e in _emitters:
		e.emitting = true
	if _anim and _anim.get_animation_list().size() > 0: 
		_anim.play("play")
	
	_auto_release()

func restart_at(node_or_vec3: Variant):
	if node_or_vec3 is Vector3: 
		if GameManager.world: GameManager.world.add_child(self)
		global_position = node_or_vec3
	elif node_or_vec3 is Node3D:
		node_or_vec3.add_child(self)
	
	for e in _emitters:
		e.restart()
		e.emitting = true
	if _anim:
		_anim.seek(0.0, true)
		if _anim.get_animation_list().size() > 0:
			_anim.play("play")
	
	_auto_release()

func stop() -> void:
	for e in _emitters:
		e.emitting = false
	if _anim:
		_anim.stop()

func _auto_release() -> void:
	if not one_shot: return
	await get_tree().create_timer(max_duration + 0.1).timeout
	queue_free()

func _load(vfx_name: StringName) -> PackedScene:
	if vfx_cache.has(vfx_name): return vfx_cache[vfx_name]
	
	var vfx_path =VFX_PATH + vfx_name + ".tscn"
	assert(FileAccess.file_exists(vfx_path), "%s is not exist." % [vfx_path])
	
	var content_scene: PackedScene = load(vfx_path)
	vfx_cache[vfx_name] = content_scene
	return content_scene

func _collect(vfx: Node3D) -> void:
	for child in vfx.get_children():
		if child is GPUParticles3D or child is CPUParticles3D: 
			_emitters.append(child)
			if child.one_shot: one_shot = true
			if child.lifetime > max_duration: max_duration = child.lifetime
		
		if child is AnimationPlayer: 
			var anim_name = "play"
			_anim = child
			if _anim.has_animation(anim_name):
				var anim: Animation = _anim.get_animation(anim_name)
				if anim.length > max_duration: max_duration = anim.length

class Line:
	static var _lines: Dictionary[StringName, PackedScene] = {
		&"bullet_line": preload("uid://cs8fnp8d00ruf"),
		&"zap": preload("uid://oelbtcgjwi8n"),
	}
	
	static func create_line(line_type: StringName) -> Line:
		if not _lines.has(line_type): return null
		var scene: PackedScene = _lines[line_type]
		var node_inst: Node3D = ObjPool.spawn(scene)
		
		return new(node_inst)
	
	var node: Node3D
	
	func _init(i_node: Node3D) -> void:
		node = i_node
	
	func fire(from: Vector3, to: Vector3) -> void:
		if not node.has_method(&"fire"): return
		node.fire(from, to)
