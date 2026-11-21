class_name SettingUI extends Control

static var show_guide_on_ready: bool = false
static var player_setting: PlayerData.Setting:
	get():
		return GameManager.player_datas.player_setting

@export var close_button: Button
@export var sensitivity_panel: Panel
@export var volume_panel: Panel
@export var show_guide_button: Button

@export_group("Guide")
@export var guide_window: Control

var sensitivity: Sensitivity
var volume: Volume

class SliderSetting:
	var panel: Panel
	var slider: HSlider
	var value_label: Label
	var custom_value: TextEdit
	
	var value: float = 100
	
	func _init(i_panel: Panel) -> void:
		panel = i_panel
		slider = panel.get_node("Slider")
		value_label = panel.get_node("Value")
		custom_value = panel.get_node("CustomValue")
		
		panel.gui_input.connect(_input)
		custom_value.gui_input.connect(_text_edit_input)
		
		value = _load_value()
		slider.value = value
		value_label.text = "%.1f" % value
	
	func _load_value(): pass
	
	func _text_edit_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				custom_value.accept_event() 
				
				custom_val(false)
	
	func _input(event: InputEvent) -> void:
		if not event.is_action_pressed("Attack"): return
		custom_val(true)
	
	func _process(_delta: float) -> void:
		if value == slider.value: return
		value = slider.value
		value_label.text = "%.1f" % value
	
	func custom_val(edit: bool) -> void:
		if edit:
			custom_value.visible = true
			custom_value.text = ""
			custom_value.grab_focus()
		else:
			custom_value.visible = false
			custom_value.release_focus()
			
			var text := custom_value.text.strip_edges()
			if text.is_valid_float():
				set_value(text.to_float())
		
		value_label.visible = not custom_value.visible
		
	func set_value(new_value: float) -> void:
		if new_value < 0: return
		slider.value = min(new_value, slider.max_value)

func _ready() -> void:
	sensitivity = Sensitivity.new(sensitivity_panel)
	volume = Volume.new(volume_panel)
	
	close_button.pressed.connect(close)
	show_guide_button.pressed.connect(show_guide)
	
	if not GameData.data_exist_on_boot_up:
		show_guide()
		GameData.data_exist_on_boot_up = true

func _process(delta: float) -> void:
	sensitivity._process(delta)
	volume._process(delta)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("Attack"): return
	for s in [sensitivity, volume]:
		if s.custom_value.has_focus() and not s.custom_value.get_global_rect().has_point(event.position):
			s.custom_val(false)

func show_guide():
	guide_window.visible = true

func close() -> void:
	visible = false
	GameManager.player_datas.player_setting.apply_setting()

#region CLASSES

class Sensitivity extends SliderSetting:
	func _load_value(): return SettingUI.player_setting.sensitivity
	
	func _process(_delta: float) -> void:
		super(_delta)
		SettingUI.player_setting.sensitivity = value
	
class Volume extends SliderSetting:
	func _load_value(): return SettingUI.player_setting.volume
	
	func _process(_delta: float) -> void:
		super(_delta)
		SettingUI.player_setting.volume = value
	
#endregion
