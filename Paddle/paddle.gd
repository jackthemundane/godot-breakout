extends AnimatableBody3D

@export var speed: float = 30.0
@export var paddle_width: float = 5
var half_width: float

func _ready() -> void:
	set_width(paddle_width)

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	var movement = Vector3(direction * speed * delta, 0, 0)
	move_and_collide(movement)

func set_width(new_width: float) -> void:
	$MeshInstance3D.mesh.size.x = new_width
	$CollisionShape3D.shape.size.x = new_width
	half_width = new_width/2

func extend_paddle(bonus: float, duration: float) -> void:
	var target_width = paddle_width + bonus
	var tween = create_tween()
	tween.tween_method(set_width, paddle_width, target_width, 0.3)
	await get_tree().create_timer(duration).timeout
	var shrink_tween = create_tween()
	shrink_tween.tween_method(set_width, target_width, paddle_width, 0.3)
	await shrink_tween.finished
	GameData.power_up_active = false
