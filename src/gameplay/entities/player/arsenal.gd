class_name Arsenal extends Node3D

@export var player: Player

var guns_slot: Dictionary[int, Gun] = {}

var current_gun: Gun
var current_gun_type: Enums.GUN_TYPES

var max_ammo: Dictionary[String, int] = {
	"BULLET" = 200,
	"SHELL" = 75,
	"ROCKET" = 50,
}

var available_ammo: Dictionary[String, int] = {
	"BULLET" = 100,
	"SHELL" = 75,
	"ROCKET" = 50,
}

var is_moving = false
var switch_timer: Timer
var slot_number: int = 1:
	set(value):
		slot_number = wrapi(value, 0, guns_slot.size())

signal on_ammo_used(type: String, amount: int)

func _ready() -> void:
	switch_timer = Timer.new()
	switch_timer.one_shot = true
	switch_timer.wait_time = 0.15
	add_child(switch_timer)
	
	_init_loadout()
	equip_slot(slot_number)

func _init_loadout():
	add_gun("hand", 0)
	
	var i_slot = 1
	for gun_name: String in GameManager.players.get_player_loadout():
		add_gun(gun_name, i_slot)
		i_slot += 1

func _unhandled_input(_event: InputEvent) -> void:
	if switch_timer.time_left > 0: return
	
	if Input.is_action_pressed("change_gun_up"):
		slot_number += 1
		equip_slot(slot_number)
		
	if Input.is_action_pressed("change_gun_down"):
		slot_number -= 1
		equip_slot(slot_number)

func equip_slot(slot: int) -> void:
	if not guns_slot.has(slot): 
		slot_number = 0
		equip_slot(slot_number)
		return
	var gun_on_slot: Gun = guns_slot[slot]
	
	if current_gun: current_gun.unequip()
	gun_on_slot.equip(self)
	current_gun = gun_on_slot
	current_gun_type = gun_on_slot.type
	switch_timer.start()
	
	change_ammo_display()
	player.player_stat_ui.arm.text = str(slot_number)

func register_kill(enemy: Enemy):
	player.on_kill.emit(enemy)

func shoot_current() -> void:
	if player.is_dead: return
	if current_gun: current_gun.shoot()

func add_gun(gun_name:String, slot: int) -> void:
	if not Ref.guns.has(gun_name): return
	
	var gun_ref: PackedScene = Ref.guns[gun_name]
	var gun_scene: Gun = gun_ref.instantiate()
	guns_slot[slot] = gun_scene
	gun_scene.unequip()
	add_child(gun_scene)

func get_ammos(type: Enums.GUN_TYPES) -> int:
	if type == Enums.GUN_TYPES.NONE: return 0
	var gun_type: String = Enums.GUN_TYPES.find_key(type)
	return available_ammo[gun_type]

func get_used_ammo() -> Array[Enums.GUN_TYPES]:
	var result: Array[Enums.GUN_TYPES] = []
	
	for slot in guns_slot:
		var gun: Gun = guns_slot[slot]
		if gun.type == Enums.GUN_TYPES.NONE: continue
		if result.has(gun.type): continue
		
		result.append(gun.type)
	
	return result

func use_ammo(type: Enums.GUN_TYPES, amount: int = 1) -> bool:
	var gun_type: String = Enums.GUN_TYPES.find_key(type)
	if not available_ammo.has(gun_type): return false
	
	var current_amount: int = available_ammo[gun_type]
	var new_amount: int = current_amount - amount
	
	if new_amount >= 0:
		available_ammo[gun_type] = max(0, new_amount)
		on_ammo_used.emit(gun_type, amount)
		return true
	else:
		return false

func change_ammo_display() -> void:
	var player_stat_ui: PlayerStatUi = player.player_stat_ui
	if not player_stat_ui: return
	
	if current_gun_type ==  Enums.GUN_TYPES.NONE:
		player_stat_ui.ammo.visible = false
		return
	else:
		player_stat_ui.ammo.visible = true
		
	player_stat_ui.ammo.text = str(get_ammos(current_gun_type))
