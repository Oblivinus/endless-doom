class_name EnemyDeadState extends State

func enter() -> void:
	parent.collision_layer = 0
	CombatManager._on_enemy_died(parent)
	
	get_tree().create_timer(5, false).timeout.connect(func():
		parent.queue_free()
	)
