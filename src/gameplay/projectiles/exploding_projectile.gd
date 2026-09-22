class_name ExplodingProjectile extends Projectile

@export var blast_radius: float = 2.0
@export_flags_3d_physics var blast_mask: int = (1 << 2)

var blast_area: Area3D

func _ready() -> void:
	super()
	
	blast_area = Area3D.new()
	blast_area.collision_layer = 0
	blast_area.collision_mask = blast_mask
	blast_area.name = "BlastArea"
	add_child(blast_area)
	
	var blast_area_shape: CollisionShape3D = CollisionShape3D.new()
	blast_area_shape.shape = SphereShape3D.new()
	blast_area_shape.shape.radius = blast_radius
	blast_area.add_child(blast_area_shape)
	blast_area_shape.debug_color = Color.RED

func _on_hit(other: Node3D):
	super(other)
	_on_explosion(get_blast_target())

func _on_explosion(targets: Array):
	#print(targets)
	pass

func get_blast_target():
	return blast_area.get_overlapping_bodies()
