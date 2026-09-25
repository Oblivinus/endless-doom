class_name HealthPotion extends Item

@export var heal_amount: float = 10

static func create() -> HealthPotion:
	return _create_from_script(HealthPotion) as HealthPotion

func _on_pickup(other: Node3D) -> void:
	super(other)
	if not other is Player: return
	other.health += heal_amount
