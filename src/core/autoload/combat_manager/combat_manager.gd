extends Node

static var BASE_DROP_CHANCE: float = 0.08
static  var FINISHER_CHANCE: float = 0.35


class CombatInfo:
	var by: Humanoid
	var type: String
	var pain_modifier: float = 1.0
	var finisher: bool = false
	
	func _init(init_type: String = "normal", ini_by: Humanoid = null) -> void:
		type = init_type
		by = ini_by

func _on_enemy_died(enemy: Enemy):
	if not Globals.world: return
	
	var is_finisher: bool = false
	
	if enemy.prev_dmg_info:
		is_finisher = enemy.prev_dmg_info.finisher
		if enemy.prev_dmg_info.by is Player:
			var player: Player = enemy.prev_dmg_info.by as Player
			player.arsenal.register_kill(enemy)
	
	if is_finisher: return
	
	var last_pos: Vector3 = enemy.global_position
	var chance = BASE_DROP_CHANCE * enemy.item_drop_chance_multiplier * GameManager.player_datas.player.drop_chance_multiplier
	chance = min(chance, 0.4)
	
	if randf() > chance: return
	
	drop_random_item(2, last_pos)

func _on_finisher(enemy: Enemy) -> void:
	if not Globals.world: return
	var last_pos: Vector3 = enemy.global_position
	var vfx = VFX.new("blood_splatter2", last_pos)
	enemy.add_child(vfx)
	vfx.restart()
	
	drop_random_item(3, last_pos)

func drop_random_item(amount: int, pos: Vector3):
	for i: int in range(amount):
		var world = GameManager.world
		world.item_spawner.spawn(world.item_spawner.item_dict.keys().pick_random(), pos)
