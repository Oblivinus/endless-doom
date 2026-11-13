class_name Ref

static var enemy_scenes: Dictionary[StringName, Variant] = {}
static var ENEMY_FOLDER_PATH = "res://src/gameplay/entities/enemies/"

static func get_enemy_scene_by_name(scene_name: StringName) -> PackedScene:
	scene_name = scene_name.to_lower()
	if enemy_scenes.has(scene_name): return enemy_scenes[scene_name]
	
	var enemy_scene_path: String = ENEMY_FOLDER_PATH + scene_name + "/" + scene_name + ".tscn"
	
	if not ResourceLoader.exists(enemy_scene_path): return null
	
	var enemy_scene: PackedScene = load(enemy_scene_path)
	enemy_scenes[scene_name] = enemy_scene
	return enemy_scene

static var guns: Dictionary[String, PackedScene] = {
	"pistol": preload("res://src/gameplay/guns/pistol.tscn"),
	"shotgun": preload("res://src/gameplay/guns/shotgun.tscn"),
	"super_shotgun": preload("res://src/gameplay/guns/super_shotgun.tscn"),
	"rocket_launcher": preload("res://src/gameplay/guns/rocket_launcher.tscn"),
	"machine_gun": preload("res://src/gameplay/guns/machine_gun.tscn"),
	"chaingun": preload("res://src/gameplay/guns/chaingun.tscn"),
	"plasma_rifle": preload("res://src/gameplay/guns/plasma_rifle.tscn"),
	"bfg_9000": preload("res://src/gameplay/guns/bfg9000.tscn"), #idk what cause bfg9000 to be turn into bfg_9000, this typo break.
	"hand": preload("res://src/gameplay/guns/hand.tscn"),
}

static var projectiles: Dictionary[String, PackedScene] = {
	"rocket": preload("res://src/gameplay/projectiles/rocket/rocket.tscn"),
	"enemy_rocket": preload("res://src/gameplay/projectiles/rocket/enemy_rocket.tscn"),
	"imp_orb": preload("res://src/gameplay/projectiles/imp_orb/imp_orb.tscn"),
	"caco_fireball": preload("res://src/gameplay/projectiles/caco_fireball/caco_fireball.tscn"),
	"bfg_orb": preload("res://src/gameplay/projectiles/bfg_orb/bfg_orb.tscn"),
	"plasma_bolt": preload("res://src/gameplay/projectiles/plasma_bolt/plasma_bolt.tscn"),
	"hell_knight_projectile": preload("res://src/gameplay/projectiles/hell_knight_projectile/hell_knight_projectile.tscn")
}

static var highlight_3d: PackedScene = preload("uid://u56cil4iogmy")
static var outline_material: ShaderMaterial = preload("res://src/core/shaders/outline_material.tres")

static var player: PackedScene = preload("uid://b413fxhnpypbp")
