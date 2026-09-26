class_name ArmorPoint extends Item

@export var armor_amount: float = 2.0

static func create() -> ArmorPoint:
	return _create_from_script(ArmorPoint) as ArmorPoint

func  _on_pickup(other: Node3D) -> void:
	super(other)
	if not other is Player: return
	other.armor += armor_amount
