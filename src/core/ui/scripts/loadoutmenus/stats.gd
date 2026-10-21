class_name Stats extends Panel

@export var container: GridContainer
@export var stat_templete: Panel

var upgrade_panels: Dictionary[StringName, UpgradePanel]

class UpgradePanel:
	var panel: Panel
	var parent: Stats
	var upgrade: PlayerData.Upgrade
	
	var add_button: Button
	var cost_label: Label
	var lvl_label: Label
	var name_label: Label
	
	func _init(i_parent: Stats, i_upgrade: PlayerData.Upgrade) -> void:
		parent = i_parent
		upgrade = i_upgrade
		
		panel = parent.stat_templete.duplicate()
		add_button = panel.get_node("AddButton")
		cost_label = panel.get_node("DPoint")
		lvl_label = panel.get_node("StatLvl")
		name_label = panel.get_node("StatName")
		
		update_visual()
		
		add_button.pressed.connect(_on_up_button)
		parent.container.add_child(panel)
		panel.visible = true
	
	func _on_up_button() -> void:
		if GameManager.player_datas.up_upgrade(upgrade.up_name): update_visual()
	
	func update_visual():
		name_label.text = Util.split_pascal( upgrade.up_name )
		cost_label.text = str(upgrade.cost) + "DP"
		lvl_label.text = "lvl: " + str(upgrade.current_lvl)
		
		if upgrade.up_name == "armor_absorption":
			name_label.text = Util.split_pascal( "armor" )
		
		if upgrade.is_maxed(): 
			add_button.visible = false
			cost_label.visible = false

func _ready() -> void:
	stat_templete.visible = false
	var player_upgrade = GameManager.player_datas.get_upgrades()
	
	for upgrade_name: StringName in player_upgrade:
		var upgrade: PlayerData.Upgrade = player_upgrade[upgrade_name]
		upgrade_panels[upgrade.up_name] = UpgradePanel.new(self, upgrade)
