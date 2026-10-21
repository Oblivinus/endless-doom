class_name EnemyDeadState extends State

func enter() -> void:
	parent.set_collision_layer_value(3, false)
	CombatManager._on_enemy_died(parent)
	
	get_tree().create_timer(5).timeout.connect(func():
		parent.queue_free()
	)
