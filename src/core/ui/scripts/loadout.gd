class_name Loadout extends Control

@export var gun_panel_template: PanelContainer
@export var selection_container: VBoxContainer
@export var close_button: Button
@export var arm_panels: Array[Panel]

var gun_panels: Dictionary[StringName, GunPanel] = {}
var arm_equiped: Array[GunPanel] = []

class GunPanel:
	static var unowned_color = Color("8c8c8cff")
	
	var panel: PanelContainer
	var gun_scene: PackedScene
	var loadout: Loadout
	var gun_name: StringName
	
	var equip_arm_slot: int = -1
	
	func  _init(scene: PackedScene, parent: Loadout) -> void:
		loadout = parent
		gun_scene = scene
		panel = parent.gun_panel_template.duplicate()
		
		panel.visible = true
		panel.gui_input.connect(_on_gui_input)
		#panel.self_modulate = unselected_color
		
		var scene_state = scene.get_state()
		var gun_label: Label = panel.get_node("GunName")
		gun_name = scene_state.get_node_name(0)
		gun_label.text = loadout.split_pascal(gun_name)
		
		loadout.selection_container.add_child(panel)
	
	func select():
		loadout.equip(self)
	
	func deselect():
		panel.visible = true
	
	func _on_gui_input(input: InputEvent):
		if input.is_action_pressed("Attack"):
			select()

func _ready() -> void:
	close_button.pressed.connect(func(): visible = false)
	
	for gun_name in Ref.guns:
		if gun_name == "hand": continue
		var gun_scene: PackedScene = Ref.guns[gun_name] as PackedScene
		var gun_panel: GunPanel = GunPanel.new(gun_scene, self)
		gun_panels[gun_panel.gun_name] = gun_panel
	
	_load_prev_loadout()
	
	_wrap_arms_slot_panel()

func _wrap_arms_slot_panel():
	var i = 0
	
	for panel in arm_panels:
		var this_i = i
		var equip_panel: PanelContainer = panel.get_node("GunPanelEquipped")
		i += 1
		
		equip_panel.gui_input.connect(func(input: InputEvent): if input.is_action_pressed("Attack"): unequip(this_i) )

func _load_prev_loadout() -> void:
	if not GameManager.players.get_player_loadout().is_empty():
		for gun_name in GameManager.players.get_player_loadout():
			equip_by_name(gun_name)
	else:
		equip_by_name("pistol")

func is_arm_empty() -> bool:
	return arm_equiped.size() == 0

func equip_by_name(gun_name: String) -> bool:
	gun_name = gun_name.to_pascal_case()
	if not gun_panels.has(gun_name): return false
	return equip(gun_panels[gun_name])

func equip(gun_panel: GunPanel) -> bool:
	if arm_equiped.size() >= arm_panels.size(): return false
	arm_equiped.append(gun_panel)
	gun_panel.panel.visible = false
	update_arm_display()
	return true

func unequip(arm_slot: int):
	if arm_slot < 0 or arm_slot >= arm_equiped.size(): return
	
	var gun_panel: GunPanel = arm_equiped[arm_slot]
	gun_panel.deselect()
	arm_equiped.remove_at(arm_slot)
	update_arm_display()

func update_arm_display():
	for panel in arm_panels:
		panel.get_node("GunPanelEquipped").visible = false
	
	for i in arm_equiped.size():
		var equip_panel: PanelContainer = arm_panels[i].get_node("GunPanelEquipped")
		equip_panel.get_node("GunName").text = split_pascal(arm_equiped[i].gun_name)
		equip_panel.visible = true
	
	get_equipped_string()

func get_equipped_string() -> Array[StringName]:
	var result: Array[StringName] = []
	
	for gun_panel in arm_equiped:
		result.append(gun_panel.gun_name.to_snake_case())
	
	return result

func split_pascal(text: String) -> String:
	var regex := RegEx.new()
	regex.compile("([a-z])([A-Z])")
	var result = regex.sub(text, "$1\n$2", true)
	return result
