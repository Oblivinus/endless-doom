class_name Chaingun extends Gun

const FIRING_TIMEOUT: float = 0.15

@onready var sprite: Sprite2D = $CanvasLayer/Control/Sprite2D
@export var init_firerate: float = 10.0
@export var fr_accel: float = 0.2
@export var fr_deaccel: float = 0.3

var last_fire: float = 0
var max_firerate: float

var _firerate_delta: float = 0:
	set(value): _firerate_delta = clampf(value, 0, 1)

var _anim_state: int = 1: 
	set(value): _anim_state = wrapi(value, 1, 3)

func _ready() -> void:
	super()
	max_firerate = fire_rate
	sprite.material.set_shader_parameter("amount", 0)

func _physics_process(delta: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	var firing := (now - last_fire) <= FIRING_TIMEOUT
	var mat = sprite.material
	
	
	if firing:
		_firerate_delta = move_toward(_firerate_delta, 1.0, fr_accel * delta)
	else:
		_firerate_delta = move_toward(_firerate_delta, 0.0, fr_deaccel * delta)
	
	mat.set_shader_parameter("amount", _firerate_delta)
	var fr: float = lerpf(init_firerate, max_firerate, _firerate_delta)
	timer.wait_time = 1.0 / fr

func play_shoot_anim() -> void:
	if _anim_state == 1:
		playback.start("shoot")
	else:
		playback.start("shoot2")
	
	_anim_state += 1

func shoot():
	if not ready_to_shoot(): return
	super()
	if last_hit_count < 1:
		create_bullet_hit_ray(farthest_center_vector())
	
	last_fire = Time.get_ticks_msec() / 1000.0

func consume_ammo():
	var chance = randf()
	if chance <= 0.25:
		super()

func play_sfx():
	var vfx = GameManager.play_hearable_sound(sfx, self)
	vfx.pitch_scale = randf_range(1.15, 1.3)
	vfx.max_db = -1.5
	vfx.play()
