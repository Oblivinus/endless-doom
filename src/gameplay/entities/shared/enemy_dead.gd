class_name EnemyDeadState extends State

func enter() -> void:
	parent.set_collision_layer_value(3, false)
	Audio3dManager.play_sound_at_position(parent.sounds["death"], parent).volume_db = -5
	
	get_tree().create_timer(5).timeout.connect(func():
		parent.queue_free()
	)
