extends AnimationTree

@export var enemy: Enemy

var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	playback = get("parameters/playback")
	enemy.on_attack.connect(_on_attack)
	active = true

func _process(_delta: float) -> void:
	var player_dir = enemy.get_local_direction_to(Globals.player.global_position)
	var blend_pos = Vector2(player_dir.x, player_dir.z)
	set("parameters/idle/blend_position", blend_pos)
	set("parameters/hurt/blend_position", blend_pos)
	set("parameters/walk/blend_position", blend_pos)
	set("parameters/attack/blend_position", blend_pos)
	

#TODO: Fix this
func _on_attack() -> void:
	playback.travel("attack")
	#animation_finished.connect(func(_anim_name): playback.travel("idle"))

func _on_zombie_on_died() -> void:
	playback.start("died")
