class_name ImpAnimationTree extends AnimationTree

@export var enemy: Enemy

var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	playback = get("parameters/playback")
	enemy.on_attack.connect(_on_attack)
	enemy.on_died.connect(_on_died)
	active = true

func _process(_delta: float) -> void:
	var player_dir = enemy.get_local_direction_to(Globals.player.global_position)
	var blend_pos = Vector2(player_dir.x, player_dir.z)
	set("parameters/idle/blend_position", blend_pos)
	set("parameters/hurt/blend_position", blend_pos)
	set("parameters/walk/blend_position", blend_pos)
	set("parameters/attack/blend_position", blend_pos)
	

func _on_attack() -> void:
	if enemy.is_hurted: return
	playback.travel("attack")

func _on_died() -> void:
	playback.start("died")


func travel(node_name: String):
	playback.travel(node_name)
