@abstract class_name Item extends RigidBody3D

@export_flags_3d_physics var pick_up_mask: int = (1 << 0)
@export var pick_up_radius: float = 0.25

var collision_area: Area3D

static func _create_from_script(script: Script) -> Item:
	var path := script.resource_path.get_basename() + ".tscn"
	if ResourceLoader.exists(path):
		var packed: PackedScene = load(path)
		return packed.instantiate()
	else:
		print("scene doesn't exist for %s" % path)
		return null

static func create() -> Item:
	return _create_from_script(Item)

func _ready() -> void:
	collision_area = Area3D.new()
	collision_area.collision_layer = 0
	collision_area.collision_mask = pick_up_mask
	add_child(collision_area)
	
	var pickup_collision_shape := CollisionShape3D.new()
	pickup_collision_shape.shape = SphereShape3D.new()
	pickup_collision_shape.shape.radius = pick_up_radius
	pickup_collision_shape.debug_color = Color.RED
	collision_area.add_child(pickup_collision_shape)
	collision_area.body_entered.connect(_on_pickup)
	
	var mat := PhysicsMaterial.new()
	mat.friction = 10.0
	mat.bounce = 0.0
	physics_material_override = mat
	linear_damp = 2.0

func _on_pickup(other: Node3D) -> void:
	var hum: Humanoid = other
	if hum is Humanoid: hum.on_pick_up.emit(self)
	
	queue_free()
