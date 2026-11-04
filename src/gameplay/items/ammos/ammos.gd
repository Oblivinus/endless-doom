class_name Ammos extends Item

@export var give_all: bool = false
@export var ammo_type: Enums.GUN_TYPES = Enums.GUN_TYPES.BULLET
@export var amount: int = 2

@export var sprite: Sprite3D

var sprite_type: int = 1
var sprite_amount: int = 0

var type_dict: Dictionary[String, int] = {
	"ROCKET" = 0,
	"BULLET" = 1,
	"SHELL" = 2,
	"CELL" = 3,
}

var amount_sprite_coord: Dictionary[String, int] = {
	"BULLET" = 6,
	"SHELL" = 3,
	"ROCKET" = 3,
	"CELL" = 15,
}

static func create() -> Ammos:
	return _create_from_script(Ammos) as Ammos

func _ready() -> void:
	super()
	if ammo_type == Enums.GUN_TYPES.NONE: ammo_type = Enums.GUN_TYPES.BULLET
	
	var enum_str: String = Enums.GUN_TYPES.find_key(ammo_type)
	var sprite_amount_change: int = amount_sprite_coord[enum_str]
	
	sprite_type = type_dict[enum_str]
	
	if amount >= sprite_amount_change: sprite_amount = 1
	
	if give_all:
		sprite.frame_coords = Vector2i(1, 1)
	else:
		sprite.frame_coords = Vector2i(sprite_amount, sprite_type)

func _on_pickup(other: Node3D) -> void:
	super(other)
	if not other is Player: return
	if not other.arsenal or not other.arsenal is Arsenal: return
	var arsenal: Arsenal = other.arsenal
	
	if give_all:
		for itype: String in Enums.GUN_TYPES.keys():
			var this_type: Enums.GUN_TYPES = Enums.GUN_TYPES.get(itype)
			arsenal.use_ammo(this_type, -amount)
		return
	
	arsenal.use_ammo(ammo_type, -amount)
