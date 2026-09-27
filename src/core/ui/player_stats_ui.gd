class_name PlayerStatUi extends CanvasLayer

@export var health: Label
@export var ammo: Label
@export var armor: Label
@export var arm: Label

@export var face_hud: Sprite2D
@export var screen_modulate: ColorRect

@export var player: Player
var arsenal: Arsenal

var face_anim_face_value: Dictionary[String, int] = {
	"eye_left": 1,
	"eye_right": 2,
	"look_left": 3,
	"look_right": 4,
	"hurt_little": 5,
	"hurt_alot": 6,
	"evil_smile": 7,
}

var face_anim_face_priority: Dictionary[String, int] = {
	"eye_left": 1,
	"eye_right": 1,
	"look_left": 2,
	"look_right": 2,
	"hurt_little": 3,
	"hurt_alot": 4,
	"evil_smile": 5,
}

var on_smile_anim: bool = false
var on_hurt_anim: bool = false
var face_animation_priority: int = 0
var hurt_state: int = 0 # 6 state, start from 0

var idle_timer: Timer

const MODULATE_SPEED: float = 5.0
const HURT_FLASH_COLOR: Color = Color(1, 0, 0, 0.35)
const  DEATH_FLASH_COLOR: Color = Color(1, 0, 0, 1)
const PICKUP_FLASH_COLOR: Color = Color(1, 1, 1, 0.35)    

func _ready() -> void:
	idle_timer = Timer.new()
	idle_timer.one_shot = true
	add_child(idle_timer)
	idle_timer.start(3)
	
	arsenal = player.arsenal
	
	player.property_changed.connect(_on_property_changed)
	player.on_hurt.connect(_on_hurt)
	player.on_died.connect(_on_died)
	player.on_kill.connect(_on_kill)
	player.on_pick_up.connect(_on_pick_up)
	
	idle_timer.timeout.connect(idle)
	player.arsenal.on_ammo_used.connect(_on_ammo_used)

func _process(delta: float) -> void:
	if screen_modulate.color.a > 0 and not player.is_dead:
		screen_modulate.modulate.a = move_toward(screen_modulate.modulate.a, 0, delta)

func _on_property_changed(property_name, new_value):
	if property_name == "health":
		_handle_health_change(new_value)
	elif property_name == "armor":
		_handle_armor_change(new_value)
	pass

func _handle_health_change(new_value: float) -> void:
	health.text = str(ceili(new_value)) + "%"

func _handle_armor_change(new_value: float) -> void:
	armor.text = str(ceili(new_value)) + "%"
	
 #region Hurt Anim
func _on_hurt(dmg: float) -> void:
	change_face_hud()
	_hurt_face(dmg)
	flash_screen(HURT_FLASH_COLOR)

func _on_died() -> void:
	flash_screen(DEATH_FLASH_COLOR)
	change_face_hud(0, 100)

func _hurt_face(dmg: float) -> void:
	if on_hurt_anim: return
	var hurt_face = face_anim_face_value[calculate_dmg_intensity(dmg)]
	
	change_face_hud(hurt_face, 2)
	on_hurt_anim = true
	
	get_tree().create_timer(0.5).timeout.connect(func():
		change_face_hud(0, 3)
		face_animation_priority = 0
		on_hurt_anim = false
	)
#endregion

func _on_pick_up(item: Item):
	flash_screen(PICKUP_FLASH_COLOR)
	var sfx = Audio3D.new("gameplay/item_up", player)
	sfx.max_db = -2.5
	sfx.pitch_scale = randf_range(0.99, 1.01)
	sfx.play()

func _on_ammo_used(type_enum_string: String, _amount: int) -> void:
	var type = Enums.GUN_TYPES.get(type_enum_string)
	if type != arsenal.current_gun_type: return
	ammo.text = str(arsenal.get_ammos(type))

func idle():
	if player.is_dead: return
	var new_random_timer = randi_range(3, 5)
	idle_timer.wait_time = new_random_timer
	
	await play_face_anim("eye_left", 1.5)
	await play_face_anim("eye_right", 1.5)
	idle_timer.start()

func _on_kill(enemy: Enemy):
	if not on_smile_anim:
		on_smile_anim = true
		await play_face_anim("evil_smile", 1)
		await get_tree().create_timer(4).timeout
		on_smile_anim = false

func calculate_dmg_intensity(dmg) -> String:
	var damage_intensity = dmg / player.max_health
	
	if damage_intensity <= 0.025:
		return "hurt_little"
	else:
		return "hurt_alot"

func play_face_anim(anim_name: String, duration: float) -> void:
	if not face_anim_face_value.has(anim_name) or not face_anim_face_priority.has(anim_name): return
	
	var anim_value = face_anim_face_value[anim_name]
	var anim_priority = face_anim_face_priority[anim_name]
	change_face_hud(anim_value, anim_priority)
	
	await get_tree().create_timer(duration).timeout
	
	change_face_hud(0, 10)
	face_animation_priority = 0

func change_face_hud(x: int = -1, priority: int = 0) -> void:
	if player.is_dead:
		face_hud.frame_coords = Vector2i(0, 5)
		return
	
	var x_cord: int = face_hud.frame_coords.x
	
	if x > -1 and face_animation_priority < priority:
		x_cord = x
		face_animation_priority = priority
	
	hurt_state = get_hurt_state()
	face_hud.frame_coords = Vector2i(x_cord, hurt_state)

func flash_screen(color: Color) -> void:
	if player.is_dead:
		screen_modulate.modulate = DEATH_FLASH_COLOR
		return
	screen_modulate.modulate = color

func get_hurt_state() -> int:
	var plr_health = player.health
	
	if plr_health >= 80:
		return 0
	elif plr_health >= 60:
		return 1
	elif plr_health >= 40:
		return 2
	elif plr_health >= 20:
		return 3
	elif plr_health < 20 and plr_health > 0:
		return 4
	else:
		return 5
