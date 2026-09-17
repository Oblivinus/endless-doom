class_name FrustumShape extends ConvexPolygonShape3D


func _init(base_size: Vector2, h_angle: float, v_angle: float, depth: float) -> void:
	var hbase_x = base_size.x / 2.0
	var hbase_y = base_size.y / 2.
	
	var h_half = deg_to_rad(h_angle) / 2.0
	var v_half = deg_to_rad(v_angle) / 2.0
	
	var far_hx = hbase_x + depth * tan(h_half)
	var far_hy = hbase_y + depth * tan(v_half)
	
	var new_points = PackedVector3Array([
		#Base
		Vector3(hbase_x, hbase_y, 0),
		Vector3(hbase_x, -hbase_y, 0),
		Vector3(-hbase_x, hbase_y, 0),
		Vector3(-hbase_x, -hbase_y, 0),
		#Spread
		Vector3(far_hx, far_hy, -depth),
		Vector3(far_hx, -far_hy, -depth),
		Vector3(-far_hx, far_hy, -depth),
		Vector3(-far_hx, -far_hy, -depth),
	])
	
	points = new_points
