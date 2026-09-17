extends Gun

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	$Hit/CollisionShape3D.shape = FrustumShape.new(Vector2(1, 3), 0.0, 45, 25)
	$Hit/CollisionShape3D.position = Vector3.ZERO
	#animation.animation_finished.connect(_on_animation_finish)
	#animation.play("Idle")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Attack"):
		shoot()
