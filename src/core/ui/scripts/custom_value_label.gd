class_name CustomValueLabel extends Control

@export var display_label: Label
@export var input_label: LineEdit
@export var regex_pattern: String

var regex: RegEx = RegEx.new()
var old_text: String

func _ready() -> void:
	regex.compile(regex_pattern)
	input_label.visible = false
	
	display_label.gui_input.connect(_on_click)
	input_label.gui_input.connect(_line_edit_input)
	input_label.text_changed.connect(_on_text_change)
	set_value(1)

func _on_click(event: InputEvent) -> void:
	if not event.is_action_pressed("Attack"): return
	editting(true)

func _line_edit_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				input_label.accept_event() 
				editting(false)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("Attack"): return
	if input_label.has_focus() and not input_label.get_global_rect().has_point(event.position):
			editting(false)

func _on_text_change(new_text: String):
	if regex.search(new_text):
		old_text = new_text
	else:
		var cursor_pos = input_label.caret_column
		input_label.text = old_text
		input_label.caret_column = cursor_pos

func set_value(value: float):
	pass

func editting(state: bool) -> void:
	input_label.visible = state
	display_label.visible = not state
	
	if state:
		input_label.grab_focus()
		input_label.text = ""
	else:
		input_label.release_focus()
		
		var text := input_label.text.strip_edges()
		if text.is_valid_float():
			set_value(text.to_float())
