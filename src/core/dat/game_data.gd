class_name GameData extends Node

static var game_dat: StringName = "res://src/core/dat/game.json"
static var save_path: StringName = "D:/Godot/ProjectTest/EndlessDoom/"
static var player_dat_file: StringName = "player_dat.json"

static func _player_data_path() -> String:
	return String(save_path).path_join(player_dat_file)

static func get_gun_cost_dictionary() -> Dictionary[StringName, int]:
	var file = FileAccess.open(game_dat, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var guns_cost: Dictionary = data["GunCost"]
	
	var result: Dictionary[StringName, int] = {}
	for gun_name: StringName in guns_cost:
		result[gun_name] = int(guns_cost[gun_name])
	
	file.close()
	return result

static func get_upgrades_dictionary() -> Dictionary:
	var file = FileAccess.open(game_dat, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var upgrades: Dictionary = data["Upgrades"]
	
	file.close()
	return upgrades

static func get_wave_entries() -> Dictionary:
	var file = FileAccess.open(game_dat, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	var wave_entries: Dictionary = data.get("WavesEntries", {})
	
	file.close()
	return wave_entries

static func get_player_data() -> Dictionary:
	var file_path: StringName = save_path + player_dat_file
	if not FileAccess.file_exists(file_path): return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = str_to_var(file.get_as_text())
	file.close()
	
	return data if data is Dictionary else {}

static func get_player_setting() -> Dictionary:
	var file_path: StringName = save_path + player_dat_file
	if not FileAccess.file_exists(file_path): return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data: Dictionary = str_to_var(file.get_as_text())
	var config: Dictionary = data.get("config", {})
	
	return config

static func save_player_data(new_data: Dictionary) -> void:
	var file_path: StringName = save_path + player_dat_file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(new_data, "\t"))
	file.close()
