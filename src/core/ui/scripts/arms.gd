class_name Arms extends Control

@export var gun_panel_template: PanelContainer
@export var selection_container: VBoxContainer
@export var arm_panels: Array[Panel]

var gun_panels: Dictionary[StringName, GunPanel] = {}
var arm_equiped: Array[GunPanel] = []

class GunPanel:
	static var unowned_color = Color("8c8c8cff")
	
	var panel: PanelContainer
	var gun_scene: PackedScene
	var arms: Arms
	var gun_name: StringName
	
	var locked: bool = true
	
	var equip_arm_slot: int = -1
	
	func  _init(scene: PackedScene, parent: Arms) -> void:
		arms = parent
		gun_scene = scene
		panel = parent.gun_panel_template.duplicate()
		
		panel.visible = true
		panel.gui_input.connect(_on_gui_input)
		#panel.self_modulate = unselected_color
		
		var scene_state = scene.get_state()
		var gun_label: Label = panel.get_node("GunName")
		gun_name = scene_state.get_node_name(0).to_snake_case()
		gun_label.text = arms.split_pascal(gun_name)
		
		if Ref.guns_cost.has(gun_name):
			var locked_panel: Panel = panel.get_node("Locked")
			var cost_label: Label = locked_panel.get_node("DPoint")
			cost_label.text = str(Ref.guns_cost[gun_name]) + "DP"
		
		arms.selection_container.add_child(panel)
	
	func select() -> void:
		if locked:
			if GameManager.players.buy_gun(gun_name): arms.update_display()
		else:
			arms.equip(self)
	
	func deselect() -> void:
		panel.visible = true
	
	func lock(value: bool = true):
		var locked_panel: Panel = panel.get_node("Locked")
		locked = value
		locked_panel.visible = locked
	
	func _on_gui_input(input: InputEvent) -> void:
		if input.is_action_pressed("Attack"):
			select()

func _ready() -> void:
	
	_init_gun_selection()
	_load_prev_arms()
	_wrap_arms_slot_panel()

func _init_gun_selection() -> void:
	for gun_name in Ref.guns:
		if gun_name == "hand": continue
		var gun_scene: PackedScene = Ref.guns[gun_name] as PackedScene
		var gun_panel: GunPanel = GunPanel.new(gun_scene, self)
		gun_panels[gun_panel.gun_name] = gun_panel

func _wrap_arms_slot_panel() -> void:
	var i = 0
	
	for panel in arm_panels:
		var this_i = i
		var equip_panel: PanelContainer = panel.get_node("GunPanelEquipped")
		i += 1
		
		equip_panel.gui_input.connect(func(input: InputEvent): if input.is_action_pressed("Attack"): unequip(this_i) )

func _load_prev_arms() -> void:
	if not GameManager.players.get_player_arms().is_empty():
		for gun_name in GameManager.players.get_player_arms():
			equip_by_name(gun_name)
	else:
		equip_by_name("pistol")

func is_arm_empty() -> bool:
	return arm_equiped.size() == 0

func equip_by_name(gun_name: String) -> bool:
	if not gun_panels.has(gun_name): return false
	return equip(gun_panels[gun_name])

func equip(gun_panel: GunPanel) -> bool:
	if arm_equiped.size() >= arm_panels.size(): return false
	arm_equiped.append(gun_panel)
	gun_panel.panel.visible = false
	update_display()
	return true

func unequip(arm_slot: int) -> void:
	if arm_slot < 0 or arm_slot >= arm_equiped.size(): return
	
	var gun_panel: GunPanel = arm_equiped[arm_slot]
	gun_panel.deselect()
	arm_equiped.remove_at(arm_slot)
	update_display()

func update_display() -> void:
	for panel in arm_panels:
		panel.get_node("GunPanelEquipped").visible = false
	
	for i in arm_equiped.size():
		var equip_panel: PanelContainer = arm_panels[i].get_node("GunPanelEquipped")
		equip_panel.get_node("GunName").text = split_pascal(arm_equiped[i].gun_name)
		equip_panel.visible = true
	
	for gun_name: StringName in gun_panels:
		var gun_panel: GunPanel = gun_panels[gun_name]
		
		if not Ref.guns_cost.has(gun_name) or GameManager.players.get_owned_guns().has(gun_name):
			gun_panel.lock(false)
		else:
			gun_panel.lock()

func get_equipped_string() -> Array[StringName]:
	var result: Array[StringName] = []
	
	for gun_panel in arm_equiped:
		result.append(gun_panel.gun_name.to_snake_case())
	
	return result

func split_pascal(text: String) -> String:
	text = text.to_pascal_case()
	var regex := RegEx.new()
	regex.compile("([a-z])([A-Z])")
	var result = regex.sub(text, "$1\n$2", true)
	return result
