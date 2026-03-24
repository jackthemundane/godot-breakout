extends RigidBody3D

@export var fall_speed: float = 10.0

var power_up_type: String = "extend_paddle"

var config: Dictionary = {
	"extend_paddle": {"color": Color.GREEN, "label": "EXT"},
	"multi_ball": {"color": Color.BLUE, "label": "x3"},
}

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	gravity_scale = 0
	linear_velocity = Vector3(0, 0, fall_speed)
	
	var phys_mat = PhysicsMaterial.new()
	phys_mat.bounce = 0
	physics_material_override = phys_mat
	
	var data = config[power_up_type]
	var mat = StandardMaterial3D.new()
	mat.albedo_color = data["color"]
	$MeshInstance3D.material_override = mat
	$Label3D.text = data["label"]
	
	# Auto-destroy if not caught after 10 seconds
	await get_tree().create_timer(10.0).timeout
	if is_inside_tree():
		GameData.power_up_active = false
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("paddle"):
		match power_up_type:
			"extend_paddle":
				body.extend_paddle(3.0, 10.0)
			"multi_ball":
				_spawn_extra_balls()
				GameData.power_up_active = false
		queue_free()

func _spawn_extra_balls() -> void:
	var balls = get_tree().get_nodes_in_group("active_balls")
	if balls.is_empty():
		return
	var source_ball = balls[0]
	for i in 2:
		var new_ball = source_ball.duplicate()
		new_ball.global_position = source_ball.global_position
		source_ball.get_parent().add_child(new_ball)
		new_ball.is_launched = true
		new_ball.freeze = false
		var angle = deg_to_rad(30 + i * 30)
		new_ball.linear_velocity = Vector3(sin(angle), 0, -cos(angle)).normalized() * source_ball.current_speed
