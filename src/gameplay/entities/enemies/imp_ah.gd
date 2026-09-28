extends AnimationHandler


func  _init() -> void:
	blend_data = {
		Vector2(0, -1):  AngleParameters.new(0), #f
		Vector2(-0.5, -0.5): AngleParameters.new(1), #f l
		Vector2(-1, 0): AngleParameters.new(2), 	#l
		Vector2(-0.5, 0.5): AngleParameters.new(3), #b l
		Vector2(0, 1): AngleParameters.new(4), #b
		Vector2(0.5, -0.5): AngleParameters.new(1, true), #f r
		Vector2(1, 0): AngleParameters.new(2, true), #r
		Vector2(0.5, 0.5):  AngleParameters.new(3, true), 	#b r
}
