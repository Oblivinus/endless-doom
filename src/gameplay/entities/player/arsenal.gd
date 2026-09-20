class_name Arsenal extends Node3D

var guns_ref_map: Array[String] = [
	"pistol",
	"shotgun",
]

var guns_slot: Dictionary[int, Gun] = {}

var is_moving = false
var switch_timer: Timer
var current_gun: Gun
var slot_number: int = 2:
	set(value):
		slot_number = wrapi(value, 1, 4)

func _ready() -> void:
	switch_timer = Timer.new()
	switch_timer.one_shot = true
	switch_timer.wait_time = 0.15
	add_child(switch_timer)
	
	var i_slot = 1
	for gun_name: String in Ref.guns:
		add_gun(gun_name, i_slot)
		i_slot += 1
		
	equip_slot(slot_number)

func _unhandled_input(_event: InputEvent) -> void:
	if switch_timer.time_left > 0: return
	
	if Input.is_action_pressed("change_gun_up"):
		slot_number += 1
		equip_slot(slot_number)
		
	if Input.is_action_pressed("change_gun_down"):
		slot_number -= 1
		equip_slot(slot_number)

func equip_slot(slot: int) -> void:
	if not guns_slot.has(slot): return
	var gun_on_slot: Gun = guns_slot[slot]
	
	if current_gun: current_gun.unequip()
	gun_on_slot.equip(self)
	current_gun = gun_on_slot
	switch_timer.start()

func shoot_current() -> void:
	if current_gun: current_gun.shoot()

func add_gun(gun_name:String, slot: int) -> void:
	if not Ref.guns.has(gun_name): return
	
	var gun_ref: PackedScene = Ref.guns[gun_name]
	var gun_scene: Gun = gun_ref.instantiate()
	guns_slot[slot] = gun_scene
	gun_scene.unequip()
	add_child(gun_scene)
