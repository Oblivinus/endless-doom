extends Humanoid
var move_count = 0

func _ready() -> void:
	var target = random_target()
	move_to_finished.connect(func(vector3):
		if move_count >= 3:
			return
		print(vector3, " finished")
		move_count += 1
		move_to(random_target())
		hurt(25)
		)
	move_to(target)
	on_died.connect(func(): print("died"))
	#await get_tree().create_timer(1).timeout
	#pause_move()
	#await get_tree().create_timer(1).timeout
	#continue_move()

func random_target() -> Vector3:
	var randx = randi_range(-10, 10)
	var randz = randi_range(-10, 10)
	
	var rand_dir = Vector3(randx, 0, randz)
	return global_position + rand_dir
