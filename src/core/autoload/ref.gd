extends Node

static var enemy_scenes: Dictionary[StringName, Variant] = {}
static var ENEMY_FOLDER_PATH = "res://src/gameplay/entities/enemies/"

func get_enemy_scene_by_name(scene_name: StringName) -> PackedScene:
	scene_name = scene_name.to_lower()
	if enemy_scenes.has(scene_name): return enemy_scenes[scene_name]
	
	var enemy_scene_path: String = ENEMY_FOLDER_PATH + scene_name + "/" + scene_name + ".tscn"
	
	if not ResourceLoader.exists(enemy_scene_path): return null
	
	var enemy_scene: PackedScene = load(enemy_scene_path)
	enemy_scenes[scene_name] = enemy_scene
	return enemy_scene

var guns: Dictionary[String, PackedScene] = {
	"pistol": preload("res://src/gameplay/guns/pistol.tscn"),
	"shotgun": preload("res://src/gameplay/guns/shotgun.tscn"),
	"super_shotgun": preload("res://src/gameplay/guns/super_shotgun.tscn"),
	"rocket_launcher": preload("res://src/gameplay/guns/rocket_launcher.tscn"),
	"machine_gun": preload("res://src/gameplay/guns/machine_gun.tscn"),
	"hand": preload("res://src/gameplay/guns/hand.tscn"),
}

var projectiles: Dictionary[String, PackedScene] = {
	"rocket": preload("res://src/gameplay/projectiles/rocket/rocket.tscn"),
	"enemy_rocket": preload("res://src/gameplay/projectiles/rocket/enemy_rocket.tscn"),
	"imp_orb": preload("res://src/gameplay/projectiles/imp_orb/imp_orb.tscn"),
	"caco_fireball": preload("res://src/gameplay/projectiles/caco_fireball/caco_fireball.tscn")
}

var highlight_3d: PackedScene = preload("uid://u56cil4iogmy")
var outline_material: ShaderMaterial = preload("res://src/core/shaders/outline_material.tres")

var player: PackedScene = preload("uid://b413fxhnpypbp")
