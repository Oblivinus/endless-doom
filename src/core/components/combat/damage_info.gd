class_name DamageInfo

var by: Humanoid
var type: String

func _init(init_type: String = "normal", ini_by: Humanoid = null) -> void:
	type = init_type
	by = ini_by
