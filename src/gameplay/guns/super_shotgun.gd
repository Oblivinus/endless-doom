class_name SuperShotgun extends Shotgun

var reload_sfx: Array[StringName] = [
	"guns/super_shotgun/SSG_open",
	"guns/super_shotgun/SSG_load",
	"guns/super_shotgun/SSG_close",
]

func _ready() -> void:
	super()
	min_damage_multiplier = 0.3

func play_sfx(sfx_value: int = 0) -> void:
	if sfx_value == 0:
		GameManager.play_hearable_sound(sfx, self).play()
		return
	
	var reload_path: StringName = reload_sfx[sfx_value - 1]
	Audio3D.new(reload_path, self).play()

func hurt_enemy(enemy: Enemy) -> void:
	var this_dmg: float = damage
	var min_dmg: float = this_dmg * min_damage_multiplier
	var distance: float = global_position.distance_to(enemy.global_position)
	var applied_dmg = Util.value_falloff_distance(distance, this_dmg, min_dmg, min_distance, max_range)
	
	var dmg_info = get_damage_info()
	
	if distance > max_range/2:
		dmg_info.type = "normal"
	else:
		dmg_info.type = damage_type
	
	enemy.hurt(applied_dmg, dmg_info)
	knockback_enemy(distance, enemy)

func knockback_enemy(distance: float, enemy: Enemy):
	var magnitude: float = 17.5
	var applied_force_magnitude: float = Util.value_falloff_distance(distance, magnitude, 3.5, max_hit_count_distance, max_range/2)
	var knock_force = global_position.direction_to(enemy.global_position) * applied_force_magnitude
	
	enemy.knockback(knock_force)
