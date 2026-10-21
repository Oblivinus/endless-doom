class_name EnemyFinisherState extends State

var flash_time: float
var dead_timer: float
var alternate: int = 1

func enter() -> void:
	parent.stop_move()

func exit() -> void:
	parent.flash_sprite(Color.WHITE)

func process_physics(delta: float):
	parent.is_hurted = true
	
	if flash_time >= 0.2:
		if alternate == 1:
			parent.flash_sprite(Color(0.0, 0.07, 0.7, 1.0))
			alternate = 2
		else:
			parent.flash_sprite(Color(0.027, 0.53, 0.0, 1.0))
			alternate = 1
		
		flash_time = 0
	
	if dead_timer >= 15:
		parent.hurt(9999, CombatManager.CombatInfo.new("normal", GameManager.player_datas.player))
	
	flash_time += delta
	dead_timer += delta
