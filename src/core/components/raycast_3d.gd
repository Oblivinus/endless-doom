class_name Raycast3d extends RefCounted

var direct_body_state: PhysicsDirectSpaceState3D
var query: PhysicsRayQueryParameters3D


func _init(node3d: Node3D) -> void:
	direct_body_state = node3d.get_world_3d().direct_space_state

func from_to(origin: Vector3, target_pos: Vector3) -> void:
	query = PhysicsRayQueryParameters3D.create(origin, target_pos)

func mask(mask_layers: Array[int]) -> void:
	query.collision_mask = 0
	for layer: int in mask_layers:
		query.collision_mask |= (1 << layer - 1)

##collider, collider_id, normal, position, rid, shape
func interect() -> Dictionary:
	var result = direct_body_state.intersect_ray(query)
	return result
