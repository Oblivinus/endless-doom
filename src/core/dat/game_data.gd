class_name GameData extends Node

static var game_dat: StringName = "res://src/core/dat/game.json"

static func get_gun_cost_dictionary() -> Dictionary[StringName, int]:
	var file = FileAccess.open(game_dat, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var guns_cost: Dictionary = data["GunCost"]
	
	var result: Dictionary[StringName, int] = {}
	for gun_name: StringName in guns_cost:
		result[gun_name] = int(guns_cost[gun_name])
	
	return result

static func get_upgrades_dictionary() -> Dictionary:
	var file = FileAccess.open(game_dat, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var upgrades: Dictionary = data["Upgrades"]
	
	return upgrades
