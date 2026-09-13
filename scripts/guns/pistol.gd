extends Gun

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	animation.animation_finished.connect(_on_animation_finish)
	animation.play("Idle")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Attack"):
		shoot()
	
func _on_animation_finish():
	animation.play("Idle")
