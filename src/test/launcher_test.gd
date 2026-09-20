extends Marker3D
#
var time := 0.0
func _physics_process(delta: float) -> void:
	time += delta
	if time > 0.5:
		var launcher = ProjectileLauncher.new("rocket", global_position)
		launcher.launch(Vector3.ZERO)
		time = 0
