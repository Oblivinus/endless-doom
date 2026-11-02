class_name ObjPool extends RefCounted

const META_SCENE: StringName = &"_pool_scene"
const META_POOLED: StringName = &"_pooled"

static var pools: Dictionary[PackedScene, Array] = {}
static var _container: Node

static func _get_container() -> Node:
	if not is_instance_valid(_container):
		_container = Node.new()
		_container.name = "PoolContainer"
		var tree: SceneTree = Engine.get_main_loop() as SceneTree
		tree.root.add_child.call_deferred(_container)
	
	return _container

static func _get_list(scene: PackedScene) -> Array:
	return pools.get_or_add(scene, [])

#region INTERNAL

static func _create(scene: PackedScene) -> Node:
	var node: Node = scene.instantiate()
	node.set_meta(META_SCENE, scene)
	return node

static func _store(node: Node, list: Array) -> void:
	node.set_meta(META_POOLED, true)
	node.process_mode = Node.PROCESS_MODE_DISABLED
	if "visible" in node: node.visible = false
	
	var container: Node = _get_container()
	if node.get_parent():
		node.reparent(container, false)
	else:
		container.add_child(node)
	
	list.append(node)

#endregion

#region PUBLIC METHOD

static func spawn(scene: PackedScene, parent: Node = null) -> Node:
	var list: Array = _get_list(scene)
	var node: Node = null
	
	while not list.is_empty() and node == null:
		var candidate: Node = list.pop_back()
		if is_instance_valid(candidate):
			node = candidate
	
	if node == null:
		node = _create(scene)
	
	node.set_meta(META_POOLED, false)
	node.process_mode = Node.PROCESS_MODE_INHERIT
	
	if parent == null: parent = GameManager.world
	
	if node.get_parent():
		node.reparent(parent, false)
	else:
		parent.add_child(node)
	
	if "visible" in node: node.visible = true
	
	if node.has_method(&"_on_pool_spawn"):
		node.call(&"_on_pool_spawn")
	
	return node

static func despawn(node: Node) -> void:
	if not is_instance_valid(node): return
	if not node.has_meta(META_SCENE):
		node.queue_free()
		return
	
	if node.get_meta(META_POOLED, false): return
	node.reparent(_get_container(), false)
	
	if node.has_method(&"_on_pool_despawn"):
		node.call(&"_on_pool_despawn")
	
	_store(node, _get_list( node.get_meta(META_SCENE) ) )

static func clear() -> void:
	for list in pools.values():
		for node in list:
			if is_instance_valid(node): node.queue_free()
	
	pools.clear()

#endregion
