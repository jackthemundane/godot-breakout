extends RigidBody3D

@export var speed: float = 35.0
@export var speed_increase: float = 2.0

func _ready() -> void:
	var random_x = randf_range(-0.7, 0.7)
	linear_velocity = Vector3(random_x, 0, -1).normalized() * speed

func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0:
		linear_velocity = linear_velocity.normalized() * speed

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("brick"):
		body.hit()
	elif body.is_in_group("paddle"):
		speed = speed + speed_increase
