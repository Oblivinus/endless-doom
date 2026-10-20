class_name Util extends RefCounted

static func value_falloff_distance(distance: float, full_value:float, floor_value: float, near_dist: float, far_dist: float) -> float:
	var span = far_dist - near_dist
	if span <= 0:
		print("far_dist must be greater")
		return floor_value
	
	var t: float = clampf((distance - near_dist)/span, 0, 1)
	return lerpf(full_value, floor_value, t)
