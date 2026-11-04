class_name PlayerData extends Node

static var upgrades_dat: Dictionary = GameData.get_upgrades_dictionary()

var player: Player
var game_manager: GameManager
var d_point: int = 1000:
	set(value):
		d_point = clamp(value, 0, 999_999)

var player_arms: Array[StringName]
var owned_gun: Array[StringName] = []
var player_upgrades: Dictionary[StringName, Upgrade] = {}
var player_setting: Setting

class Upgrade:
	var up_name: StringName
	
	var current_lvl: int = 1
	var max_lvl: int
	var increase: float
	var base_cost: int = 20
	var cost: int = 20
	var cost_increase: int;
	
	func _init(nameStr: StringName, def: Dictionary) -> void:
		up_name =nameStr
		max_lvl = int( def["max"] )
		increase = def["increase"]
		
		base_cost = def.get("init_cost", 20)
		cost = get_cost()
		cost_increase = def.get("cost_increase", 5)
	
	func up(level: int = 0):
		if is_maxed(): return
		if level > 0:
			current_lvl = min(level, max_lvl)
		else:
			current_lvl = min(current_lvl + 1, max_lvl)
		cost = get_cost()
	
	func get_cost() -> int:
		return base_cost + (current_lvl - 1) * cost_increase
	
	func is_maxed() -> bool:
		return current_lvl >= max_lvl
	
	func get_value() -> float:
		return (current_lvl - 1) * increase
	
	func to_dict() -> Dictionary:
		var result = {
			"name": up_name,
			"lvl": current_lvl
		}
		return result

class Setting:
	const REFERENCE_SEN: float = 100.0
	var sensitivity: float = 100.0
	
	func _init() -> void:
		var player_config: Dictionary = GameData.get_player_setting()
		for config_name: StringName in player_config:
			var value: Variant = player_config[config_name]
			if self.get(config_name): self.set(config_name, value)
	
	func apply_setting_from_dict(dict: Dictionary[StringName, Variant]) -> void:
		for sett_name: StringName in dict:
			var value: Variant = dict[sett_name]
			if self.get(sett_name): self.set(sett_name, value)
		
		apply_setting()
	
	func apply_setting() -> void:
		Player.mouse_sens = 0.25 * (sensitivity / REFERENCE_SEN)
		Player.mouse_sens = max(Player.mouse_sens, 0.05)
	
	func get_setting_dict() -> Dictionary[StringName, Variant]:
		var result: Dictionary[StringName, Variant] = {
			&"sensitivity": sensitivity,
		}
		
		return result

func init(parent) -> void:
	game_manager = parent
	player_setting = Setting.new()
	
	for upgrade_name: StringName in upgrades_dat:
		player_upgrades[upgrade_name] = Upgrade.new( upgrade_name, upgrades_dat[upgrade_name] )
	
	load_player_data()

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

#region PUBLIC PLAYER METHOD
func get_player() -> Player:
	return player
	
func get_player_ammo_used() -> Array[Enums.GUN_TYPES]:
	var arsenal: Arsenal = player.arsenal
	return arsenal.get_used_ammo()
	
func get_player_arms() -> Array[StringName]:
	return player_arms
	
func set_player_arms(value: Array[StringName]) -> void:
	player_arms = value

func load_player_data() -> void:
	var disk_data: Dictionary = GameData.get_player_data()
	print(disk_data)
	
	owned_gun.assign( disk_data.get("GunOwned", []) )
	player_arms.assign( disk_data.get("PrevArm", []) )
	d_point = disk_data.get("DPoints", d_point)
	
	for upgrade_data in disk_data.get("Upgrades", []):
		if not player_upgrades.has(upgrade_data["name"]) or not upgrade_data.has("lvl"): continue
		var upgrade = player_upgrades[upgrade_data["name"]]
		upgrade.up(upgrade_data["lvl"])
#endregion

#region PLAYER DATA METHOD
func get_upgrades() -> Dictionary:
	return player_upgrades

func get_upgrades_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for upgrade_name: StringName in player_upgrades:
		var upgrade = player_upgrades[upgrade_name]
		result.append(upgrade.to_dict())
	
	return result

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

func get_player_data() -> Dictionary:
	var gun_owned = get_owned_guns()
	var upgrades = get_upgrades_data()
	var prev_arm = get_player_arms()
	var max_wave: int = game_manager.last_wave
	
	var result = {
		"GunOwned": gun_owned,
		"Upgrades": upgrades,
		"PrevArm": prev_arm,
		"DPoints": d_point,
		"MaxWave": max_wave,
		"config": player_setting.get_setting_dict()
	}
	
	return result
#endregion
