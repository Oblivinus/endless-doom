extends Node

static var cached: Dictionary[StringName, Variant] = {}

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
	"imp_orb": preload("res://src/gameplay/projectiles/imp_orb/imp_orb.tscn"),
	"caco_fireball": preload("res://src/gameplay/projectiles/caco_fireball/caco_fireball.tscn")
}

var highlight_3d: PackedScene = preload("uid://u56cil4iogmy")
var outline_material: ShaderMaterial = preload("res://src/core/shaders/outline_material.tres")

var player: PackedScene = preload("uid://b413fxhnpypbp")
