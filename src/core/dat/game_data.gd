class_name GameData extends Node

static var game_dat: StringName = "res://src/core/dat/game.json"
static var save_path: StringName = _resolve_save_dir()
static var player_dat_file: StringName = "endless_plrdat.doomsav"

const LEGACY_DAT_FILE := "endless_plrdat.json"
const SAVE_PASS := "67sIgmA69tUnG3sAHur" #HEY! NO CHEATING ALLOWED, SKILL ISSUE.

static var data_exist_on_boot_up: bool = true

static func init():
	data_exist_on_boot_up = FileAccess.file_exists(_player_data_path())
	if not data_exist_on_boot_up:
		save_player_data({})

static func _player_data_path() -> String:
	return String(save_path).path_join(player_dat_file)

static func _legacy_path() -> String:
	return String(save_path).path_join(LEGACY_DAT_FILE)

static func _resolve_save_dir() -> String:
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://")  # next to project.godot
	var dir := OS.get_executable_path().get_base_dir()
	
	var test_path := dir.path_join(".write_test")
	var t := FileAccess.open(test_path, FileAccess.WRITE)
	if t == null:
		push_warning("Exe dir not writable (%s), falling back to user://" % error_string(FileAccess.get_open_error()))
		return ProjectSettings.globalize_path("user://")
	t.close()
	DirAccess.remove_absolute(test_path)
	return dir

# ---------- player save (encrypted) ----------
static func _read_save() -> Dictionary:
	var path := _player_data_path()

	if FileAccess.file_exists(path):
		var f := FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SAVE_PASS)
		if f == null:
			push_warning("Save unreadable (corrupt or wrong key): %s" % error_string(FileAccess.get_open_error()))
			return {}
		var parsed = JSON.parse_string(f.get_as_text())
		f.close()
		return parsed if parsed is Dictionary else {}
	
	if FileAccess.file_exists(_legacy_path()):
		var old := FileAccess.open(_legacy_path(), FileAccess.READ)
		var parsed = JSON.parse_string(old.get_as_text())
		old.close()
		if parsed is Dictionary:
			save_player_data(parsed)
			return parsed
	
	return {}

static func get_player_data() -> Dictionary:
	return _read_save()

static func get_player_setting() -> Dictionary:
	return _read_save().get("config", {})

static func save_player_data(new_data: Dictionary) -> void:
	var path := _player_data_path()
	var tmp := path + ".tmp"
	
	var f := FileAccess.open_encrypted_with_pass(tmp, FileAccess.WRITE, SAVE_PASS)
	if f == null:
		push_error("Can't write save: %s" % error_string(FileAccess.get_open_error()))
		return
	f.store_string(JSON.stringify(new_data, "\t"))
	f.close()
	
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	
	var err := DirAccess.rename_absolute(tmp, path)
	if err != OK:
		push_error("Rename failed (%s), writing directly" % error_string(err))
		
		var direct := FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SAVE_PASS)
		if direct:
			direct.store_string(JSON.stringify(new_data, "\t"))
			direct.close()
	

# ---------- game.json ----------
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
