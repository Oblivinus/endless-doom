class_name PlayerData extends Node

static var upgrades_dat: Dictionary = GameData.get_upgrades_dictionary()

var player: Player
var game_manager: GameManager
var d_point: int = 9999:
	set(value):
		d_point = clamp(value, 0, 999_999)

var player_loadout: Array[StringName]
var owned_gun: Array[StringName] = []
var player_upgrades: Dictionary[StringName, Upgrade] = {}

class Upgrade:
	var up_name: StringName
	
	var current_lvl: int = 1
	var max_lvl: int
	var increase: float
	var cost: int = 20
	var cost_increase: int;
	
	func _init(nameStr: StringName, def: Dictionary) -> void:
		up_name =nameStr
		max_lvl = int( def["max"] )
		increase = def["increase"]
		cost = def.get("init_cost", 20)
		cost_increase = def.get("cost_increase", 5)
	
	func up():
		if is_maxed(): return
		current_lvl += 1
		cost += cost_increase
	
	func is_maxed() -> bool:
		return current_lvl >= max_lvl
	
	func get_value() -> float:
		return (current_lvl - 1) * increase



func init(parent) -> void:
	game_manager = parent
	
	for upgrade_name: StringName in upgrades_dat:
		player_upgrades[upgrade_name] = Upgrade.new( upgrade_name, upgrades_dat[upgrade_name] )
	
func _on_player_respawn(new_player: Player):
	player = new_player
	player.on_kill.connect(_on_enemy_kill)
	
	_apply_upgrade()
	
func _on_enemy_kill(enemy: Enemy) -> void:
	var d_point_earned = randi_range(enemy.d_point_drop[0], enemy.d_point_drop[1])
	add_d_coint(d_point_earned)

func _apply_upgrade() -> void:
	
	player.move_speed += player_upgrades["move_speed"].get_value()
	player.armor_absorption += player_upgrades["armor_absorption"].get_value()
	player.max_health += player_upgrades["max_health"].get_value()
	player.damage_boost += player_upgrades["damage"].get_value()
	player.drop_chance_multiplier += player_upgrades["drop_chance"].get_value()
	
	pass

func get_player() -> Player:
	return player
	
func get_player_ammo_used() -> Array[Enums.GUN_TYPES]:
	var arsenal: Arsenal = player.arsenal
	return arsenal.get_used_ammo()
	
func get_player_arms() -> Array[StringName]:
	return player_loadout
	
func set_player_arms(value: Array[StringName]) -> void:
	player_loadout = value

func get_upgrades() -> Dictionary:
	return player_upgrades

func up_upgrade(up_name: StringName) -> bool:
	if not player_upgrades.has(up_name): return false
	if player_upgrades[up_name].is_maxed(): return false
	var upgrade := player_upgrades[up_name]
	
	if d_point >= upgrade.cost:
		d_point -= upgrade.cost
		upgrade.up()
		return true
	else:
		print("Not Enough")
		return false

func add_d_coint(value: int) -> void:
	d_point += value
	
func buy_gun(gun_name: StringName) -> bool:
	if not game_manager.guns_cost.has(gun_name): return false
	var cost: int = game_manager.guns_cost[gun_name]
		
	if d_point >= cost:
		d_point -= cost
		owned_gun.append(gun_name)
			
	return true
	
func get_owned_guns() -> Array[StringName]:
	return owned_gun
