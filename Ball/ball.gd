extends RigidBody3D

@export var speed: float = 35
	
func _ready() -> void:
	var random_x = randf_range(-0.7, 0.7)
	linear_velocity = Vector3(random_x, 0, -1).normalized() * speed

func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0:
		linear_velocity = linear_velocity.normalized() * speed
