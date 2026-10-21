class_name LoadoutMenus extends Control

@export var close_button: Button
@export var dpoints: Label

@export var arms: Arms

func _ready() -> void:
	close_button.pressed.connect(func(): visible = false )

func _process(_delta: float) -> void:
	dpoints.text = "DPoints: " + str(GameManager.player_datas.d_point)
