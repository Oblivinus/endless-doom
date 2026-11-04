class_name SettingUI extends Control

static var player_setting: PlayerData.Setting:
	get():
		return GameManager.player_datas.player_setting

@export var close_button: Button
@export var sensitivity_panel: Panel

var sensitivity: Sensitivity

class Sensitivity:
	var panel: Panel
	var slider: HSlider
	var value_label: Label
	var custom_value: TextEdit
	
	var value: float = 25
	
	func _init(i_panel: Panel) -> void:
		panel = i_panel
		slider = panel.get_node("Slider")
		value_label = panel.get_node("Value")
		custom_value = panel.get_node("CustomValue")
		
		value = SettingUI.player_setting.sensitivity
		slider.value = value
		value_label.text = "%.1f" % value
		
		panel.gui_input.connect(_input)
		custom_value.gui_input.connect(_text_edit_input)
	
	func _input(event: InputEvent) -> void:
		if not event.is_action_pressed("Attack"): return
		custom_sens(true)
	
	func _process(_delta: float) -> void:
		if value == slider.value: return
		value = slider.value
		SettingUI.player_setting.sensitivity = value
		value_label.text = "%.1f" % value
	
	func _text_edit_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				custom_value.accept_event() 
				
				custom_sens(false)
	
	func set_value(new_value: float) -> void:
		if new_value <= 0: return
		slider.value = min(new_value, slider.max_value)
	
	func custom_sens(edit: bool) -> void:
		if edit:
			custom_value.visible = true
			custom_value.text = ""
			custom_value.grab_focus()
		else:
			custom_value.visible = false
			custom_value.release_focus()
			var new_value: float =  float(custom_value.text) 
			set_value(new_value)
		
		value_label.visible = not custom_value.visible


func _ready() -> void:
	sensitivity = Sensitivity.new(sensitivity_panel)
	
	close_button.pressed.connect(close)

func _process(delta: float) -> void:
	sensitivity._process(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Attack"):
		if sensitivity.custom_value.has_focus() and not sensitivity.custom_value.get_global_rect().has_point(event.position):
				sensitivity.custom_sens(false)

func get_setting_dict() -> Dictionary:
	var result: Dictionary = {
		&"sensitivity": sensitivity.value,
	}
	
	return result

func close() -> void:
	visible = false
	GameManager.player_datas.player_setting.apply_setting()
