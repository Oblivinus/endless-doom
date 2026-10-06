extends Node

var guns: Dictionary[String, PackedScene] = {
	"pistol": preload("res://src/gameplay/guns/pistol.tscn"),
	"shotgun": preload("res://src/gameplay/guns/shotgun.tscn"),
	"rocket_launcher": preload("res://src/gameplay/guns/rocket_launcher.tscn"),
	"machine_gun": preload("res://src/gameplay/guns/machine_gun.tscn"),
}

var projectiles: Dictionary[String, PackedScene] = {
	"rocket": preload("res://src/gameplay/projectiles/rocket/rocket.tscn"),
	"imp_orb": preload("res://src/gameplay/projectiles/imp_orb/imp_orb.tscn")
}

var highlight_3d: PackedScene = preload("uid://u56cil4iogmy")

var player: PackedScene = preload("uid://b413fxhnpypbp")
