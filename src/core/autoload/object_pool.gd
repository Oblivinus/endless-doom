class_name ObjPool extends RefCounted

const META_SOURCE: StringName = &"_pool_source"
const META_POOLED: StringName = &"_pooled"

static var pools: Dictionary[Variant, Array] = {}
static var _container: Node

static func _get_container() -> Node:
	if not is_instance_valid(_container):
		_container = Node.new()
		_container.name = "PoolContainer"
		var tree: SceneTree = Engine.get_main_loop() as SceneTree
		tree.root.add_child.call_deferred(_container)
	
	return _container

static func _get_list(source: Variant) -> Array:
	return pools.get_or_add(source, [])

#region INTERNAL

static func _create(source: Variant) -> Node:
	var node: Node = source.instantiate()
	
	if source is PackedScene:
		node = source.instantiate()
	elif source is GDScript:
		node = source.new()
	else:
		assert(false, "Source must be tscn or GDscript")
	
	node.set_meta(META_SOURCE, source)
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

static func _call_hook(node: Node, hook: StringName, args: Array) -> void:
	if not node.has_method(hook): return
	if node.get_method_argument_count(hook) > 0:
		node.call(hook, args)
	else:
		node.call(hook)

#endregion

#region PUBLIC METHOD

static func spawn(source: Variant, parent: Node = null, args: Array = []) -> Node:
	var list: Array = _get_list(source)
	var node: Node = null
	
	while not list.is_empty() and node == null:
		var candidate: Node = list.pop_back()
		if is_instance_valid(candidate):
			node = candidate
	
	if node == null:
		node = _create(source)
	
	node.set_meta(META_POOLED, false)
	node.process_mode = Node.PROCESS_MODE_INHERIT
	
	if parent == null: parent = GameManager.world
	
	if node.get_parent():
		node.reparent(parent, false)
	else:
		parent.add_child(node)
	
	if "visible" in node: node.visible = true
	
	_call_hook(node, &"_on_pool_spawn", args)
	
	return node

static func despawn(node: Node) -> void:
	if not is_instance_valid(node): return
	if not node.has_meta(META_SOURCE):
		node.queue_free()
		return
	
	if node.get_meta(META_POOLED, false): return
	node.reparent(_get_container(), false)
	
	_call_hook(node, &"_on_pool_despawn", [])
	_store(node, _get_list( node.get_meta(META_SOURCE) ) )

static func clear() -> void:
	for list in pools.values():
		for node in list:
			if is_instance_valid(node): node.queue_free()
	
	pools.clear()

#endregion
