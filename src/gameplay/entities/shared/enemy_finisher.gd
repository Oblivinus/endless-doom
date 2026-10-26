class_name EnemyFinisherState extends State

var dead_timer: float
var alternate: int = 1

func enter() -> void:
	parent.stop_move()
	parent.flash_finisher_outline()
	parent.set_collision_layer_value(8, true)

func exit() -> void:
	parent.flash_sprite(Color.WHITE)
	parent.flash_finisher_outline(false)
	parent.set_collision_layer_value(8, false)

func process_physics(delta: float):
	parent.in_pain = true
	
	if dead_timer >= 15:
		parent.hurt(parent.max_health, CombatManager.CombatInfo.new("normal", GameManager.player_datas.player))
	
	dead_timer += delta
