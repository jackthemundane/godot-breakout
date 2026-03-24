extends RigidBody3D

@export var starting_speed: float = 35.0
@export var current_speed: float = 35.0
@export var speed_increase: float = 2.0
@export var paddle_path: NodePath

var is_launched: bool = false
var paddle: Node3D

func _ready() -> void:
	paddle = get_node(paddle_path)
	freeze = true
	add_to_group("active_balls")

func _physics_process(delta: float) -> void:
	if not is_launched:
		
		global_position = paddle.global_position + Vector3(0, 0, -1.0)
		
		if Input.is_action_just_pressed("launch"):
			launch()
	else:
		
		if linear_velocity.length() > 0:
			linear_velocity = linear_velocity.normalized() * current_speed

func launch() -> void:
	is_launched = true
	freeze = false
	var random_x = randf_range(-0.7, 0.7)
	linear_velocity = Vector3(random_x, 0, -1).normalized() * current_speed

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("brick"):
		body.hit()
	elif body.is_in_group("paddle"):
		current_speed = current_speed + speed_increase
		bounce_off_paddle(body)
		GameData.reset_multiplier()

func reset() -> void:
	is_launched = false
	freeze = true
	linear_velocity = Vector3.ZERO
	current_speed = starting_speed
	add_to_group("active_balls")

func bounce_off_paddle(paddle_body: Node3D) -> void:
	var offset = (global_position.x - paddle_body.global_position.x) / paddle_body.half_width
	offset = clamp(offset, -1.0, 1.0)
	
	var max_angle = 1.2 
	var angle = offset * max_angle
	
	var direction = Vector3(sin(angle), 0, -cos(angle)).normalized()
	linear_velocity = direction * current_speed
