extends AnimationTree

@export var enemy: Enemy

var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	playback = get("parameters/playback")
	active = true

func _process(_delta: float) -> void:
	var player_dir = enemy.get_local_direction_to(Globals.player.global_position)
	var blend_pos = Vector2(player_dir.x, player_dir.z)
	set("parameters/idle/blend_position", blend_pos)
	set("parameters/hurt/blend_position", blend_pos)
	set("parameters/walk/blend_position", blend_pos)
	

func _on_zombie_on_died() -> void:
	playback.start("died")
