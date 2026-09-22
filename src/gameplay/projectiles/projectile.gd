class_name Projectile extends RigidBody3D

@export var speed := 10.0
@export var collision_radius := 0.1

@export_flags_3d_physics var hit_mask: int= 1
var hit_area: Area3D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	gravity_scale = 0.0
	
	var body_shape := CollisionShape3D.new()
	body_shape.shape = SphereShape3D.new()
	body_shape.shape.radius = collision_radius
	add_child(body_shape)
	
	hit_area = Area3D.new()
	hit_area.collision_layer = 0
	hit_area.collision_mask = hit_mask
	hit_area.monitoring = true
	hit_area.monitorable = false
	add_child(hit_area)
	
	var area_shape = CollisionShape3D.new()
	area_shape.shape = SphereShape3D.new()
	area_shape.shape.radius = collision_radius
	hit_area.add_child(area_shape)
	
	hit_area.body_entered.connect(_on_hit)

func launch(direction: Vector3):
	linear_velocity = direction.normalized() * speed

func ovewrite_mask(masks_layers:Array[int]):
	hit_area.collision_mask = 0
	for layer in masks_layers:
		hit_area.collision_mask |= (1 << layer - 1)
		
func xor_mask(masks_layers:Array[int]):
	hit_area.collision_mask = 0
	for layer in masks_layers:
		hit_area.collision_mask ^= (1 << layer - 1)

func _on_hit(other: Node3D):
	#print(other.name)
	queue_free()

func trigger_on_hit():
	_on_hit(null)
	queue_free()
