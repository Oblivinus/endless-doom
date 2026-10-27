class_name Util extends RefCounted

class CombatInfo:
	var by: Humanoid
	var type: String
	var pain_modifier: float = 1.0
	
	func _init(init_type: String = "normal", ini_by: Humanoid = null) -> void:
		type = init_type
		by = ini_by

static var cached: Dictionary[StringName, Variant] = {}

static func value_falloff_distance(distance: float, full_value:float, floor_value: float, near_dist: float, far_dist: float) -> float:
	var span = far_dist - near_dist
	if span <= 0:
		print("far_dist must be greater")
		return floor_value
	
	var t: float = clampf((distance - near_dist)/span, 0, 1)
	return lerpf(full_value, floor_value, t)

static func split_pascal(text: String) -> String:
	text = text.to_pascal_case()
	var regex := RegEx.new()
	regex.compile("([a-z])([A-Z])")
	var result = regex.sub(text, "$1 $2", true)
	return result

static func split_pascal_enter(text: String) -> String:
	text = text.to_pascal_case()
	var regex := RegEx.new()
	regex.compile("([a-z])([A-Z])")
	var result = regex.sub(text, "$1\n$2", true)
	return result

static func create_area_3d(parent: Node3D, shape: Shape3D, collision_mask: Array[int]) -> Area3D:
	var area = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0
	for layer in collision_mask:
		area.collision_mask |= (1 << layer - 1)
	
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = shape
	area.add_child(collision_shape)
	parent.add_child(area)
	
	return area
