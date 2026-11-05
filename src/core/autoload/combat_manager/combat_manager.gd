extends Node

static var BASE_DROP_CHANCE: float = 0.08
static  var FINISHER_CHANCE: float = 0.1

func roll_damage_range(d_range: Array[float]) -> float:
	var base_damage: float = d_range[0]
	var max_damage: float = base_damage * d_range[1]
	var multiplier: float = d_range[2] if d_range.size() >= 0 and 2 < d_range.size() else 1.0
	
	var result: float = range(base_damage, max_damage + base_damage, base_damage).pick_random()
	result *= multiplier
	
	return result

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
	
	if is_finisher or enemy is LostSoul: return
	
	var last_pos: Vector3 = enemy.global_position
	var chance = BASE_DROP_CHANCE * enemy.item_drop_chance_multiplier * GameManager.player_datas.player.drop_chance_multiplier
	chance = min(chance, 0.4)
	
	if randf() > chance: return
	
	drop_random_item(2, last_pos)

func _on_finisher(enemy: Enemy) -> void:
	if not Globals.world: return
	var last_pos: Vector3 = enemy.global_position
	var vfx = VfxConstructor.new("blood_splatter")
	vfx.restart_at(enemy)
	
	drop_random_item(4, last_pos)

func drop_random_item(amount: int, pos: Vector3):
	var world = GameManager.world
	world.item_spawner.spawn_random_batch(amount, pos)
	
