class_name EnemyDeadState extends State

func enter() -> void:
	parent.set_collision_layer_value(3, false)
	Audio3D.new("zombie_death1", parent).play()
	
	get_tree().create_timer(5).timeout.connect(func():
		parent.queue_free()
	)
