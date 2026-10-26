class_name Projectile extends RigidBody3D

@export var speed := 10.0
@export var collision_radius := 0.1
@export var life_time := 5.0
@export_flags_3d_physics var hit_mask: int= 1

var _active: bool = false
var pool_name: StringName

var hit_area: Area3D
var lifetime_timer: Timer

signal on_hit(hum: Humanoid)

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
	
	lifetime_timer = Timer.new()
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = life_time
	add_child(lifetime_timer)
	
	lifetime_timer.start()
	lifetime_timer.timeout.connect(trigger_on_hit)
	lock_rotation = true
	
	_set_inactive_state()

func launch(direction: Vector3) -> void:
	linear_velocity = direction.normalized() * speed
	look_at(global_position + linear_velocity.normalized())

func ovewrite_mask(masks_layers:Array[int]) -> void:
	hit_area.collision_mask = 0
	for layer in masks_layers:
		hit_area.collision_mask |= (1 << layer - 1)
		
func xor_mask(masks_layers:Array[int]) -> void:
	hit_area.collision_mask = 0
	for layer in masks_layers:
		hit_area.collision_mask ^= (1 << layer - 1)

func _on_hit(other: Node3D) -> void:
	if not _active: return
	_active = false
	on_hit.emit(other)
	_release.call_deferred()

func trigger_on_hit() -> void:
	_on_hit(null)

#region POOLING
func activate(pos: Vector3) -> void:
	global_position = pos
	hit_area.collision_mask = hit_mask   # reset any overwritten mask
	hit_area.set_deferred("monitoring", true)
	freeze = false
	set_process(true)
	set_physics_process(true)
	show()
	lifetime_timer.start(life_time)
	_active = true

func _set_inactive_state() -> void:
	_active = false
	lifetime_timer.stop()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
	hit_area.set_deferred("monitoring", false)
	set_process(false)
	set_physics_process(false)
	hide()

func _release() -> void:
	_set_inactive_state()
	
	# Drop all listeners from the previous shot
	for c in on_hit.get_connections():
		on_hit.disconnect(c.callable)
	
	if get_parent():
		get_parent().remove_child(self)
	ProjectileLauncher.return_to_pool(self)

func is_active() -> bool:
	return _active

#endregion
