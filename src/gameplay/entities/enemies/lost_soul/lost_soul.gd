class_name LostSoul extends FlyingEnemy

const DASH_DURATION: float = 1.0

var explode_hitbox: Area3D
@export var explode_damage: float = 8.0
var lifetime: float = -1
var life_timer: Timer

var dash_hitbox: Area3D
var dash_speed: float = 17.5
var dash_duration: float = DASH_DURATION

var is_dashing: bool = false
var dash_dir: Vector3 = Vector3.ZERO

@onready var char_hitbox = $CollisionShape3D

static var lost_soul_scene: PackedScene = preload("uid://h28jo08emsc6")

static func spawn_to_attack(i_target: Humanoid, pos: Vector3, parent: Node, target_pos: Vector3 = Vector3.ZERO, duration: float = -1, i_lifetime: float = -1) -> void:
	var this_lost_soul: LostSoul = lost_soul_scene.instantiate() as LostSoul
	
	this_lost_soul.target = i_target
	this_lost_soul.lifetime = i_lifetime
	
	var launch_pos = this_lost_soul.target.global_position
	if target_pos != Vector3.ZERO:
		launch_pos = target_pos
	
	if duration > 0: this_lost_soul.dash_duration = duration
	
	parent.add_child(this_lost_soul)
	this_lost_soul.global_position = pos
	this_lost_soul.attack_at_position(launch_pos, false, true)  # force = true
	this_lost_soul.dash_duration = DASH_DURATION
	

func _ready() -> void:
	super()
	
	if lifetime > 0:
		life_timer = Timer.new()
		life_timer.one_shot = true
		life_timer.wait_time = lifetime
		life_timer.timeout.connect(func(): health = 0)
		add_child(life_timer)
		life_timer.start()
		
	explode_hitbox = _create_sphere_hitbox(2, [1])
	dash_hitbox = _create_sphere_hitbox(0.55, [1])
	
	dash_hitbox.body_entered.connect( _on_hit )
	
	add_child(explode_hitbox)
	add_child(dash_hitbox)

func _create_sphere_hitbox(radius: float, masks: Array[int]) -> Area3D:
	var area: Area3D = Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 0
	for mask in masks:
		area.collision_mask |= (1 << (mask - 1))
	
	var shape: SphereShape3D = SphereShape3D.new()
	shape.radius = radius
	
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = shape
	collision_shape.debug_color = Color.RED
	area.add_child(collision_shape)
	
	return area

func _process_gravity(delta):
	if is_dead:
		velocity.y = 0

func _process_moving(delta: float) -> void:
	if in_pain: _end_dash()
	
	if is_dashing and not is_dead:
		velocity = dash_dir * dash_speed
		
		if is_on_wall():
			_end_dash()
		return
	hover_smoothing = move_toward(hover_smoothing, 4.0, delta * 2)
	super(delta)

func _on_hit(obj: Humanoid):
	if not obj is Humanoid: return
	obj.hurt(attack_damage)

func _on_died() -> void:
	super()
	var targets = explode_hitbox.get_overlapping_bodies()
	
	for hum: Humanoid in targets:
		hum.hurt(explode_damage)

func attack_at_position(target_pos: Vector3, delay: bool = true, force: bool = false) -> void:
	if in_pain or is_on_cooldown() or is_attacking: return
	
	var target_no_y := Vector3(target_pos.x, global_position.y, target_pos.z)
	var current_distance: float = get_target_distance()
	
	on_attack.emit()
	attack_timer.start()
	look_at(target_no_y)
	stop_move()
	is_disturbed = false
	is_attacking = true
	attack_pos = target_pos
	
	if delay: await get_tree().create_timer(attack_delay).timeout
	
	if force:
		if not is_dead: attack_action()
	else:
		_attack_sequeance(current_distance)
	is_attacking = false

func attack_action() -> void:
	animation_tree.travel("attack")
	dash_to_pos(attack_pos)

func dash_to_pos(target_pos: Vector3) -> void:
	if is_dashing: return
	Audio3D.new("ls/lost_soul_attack", self).play()
	dash_dir = (target_pos - global_position).normalized()
	stop_move()
	knockback_instance.stop()
	is_dashing = true
	
	await get_tree().create_timer(dash_duration).timeout
	_end_dash()

func _end_dash() -> void:
	if not is_dashing: return
	is_dashing = false
	velocity = Vector3.ZERO
	if not is_dead: animation_tree.travel("idle")
	
	hover_smoothing = 0.5
	choose_new_hover_offset()

func choose_new_hover_offset() -> void:
	hover_offset = randf_range(2, 6)

func knockback(force: Vector3) -> void:
	if is_dashing: return
	super(force)
