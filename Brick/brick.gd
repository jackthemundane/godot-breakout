extends StaticBody3D

@export_enum("standard", "tough", "unbreakable") var brick_type: String = "standard"
@export var power_up_scene: PackedScene

var data: Dictionary
var health: int

func _ready() -> void:
	data = GameData.brick_types[brick_type]
	health = data["health"]
	var material = StandardMaterial3D.new()
	material.albedo_color = data["color"]
	$MeshInstance3D.material_override = material
	if brick_type != "unbreakable":
		add_to_group("destructible")

func hit() -> void:
	if health == -1:
		return
	health -= 1
	$MeshInstance3D.material_override.albedo_color = $MeshInstance3D.material_override.albedo_color.darkened(0.4)
	if health <= 0:
		GameData.add_score(data["points"])
		remove_from_group("destructible")
		GameData.check_level_clear()
		_try_drop_power_up()
		queue_free()

func _try_drop_power_up() -> void:
	if GameData.power_up_active:
		return
	if randf() < GameData.power_up_drop_chance:
		if power_up_scene:
			GameData.power_up_active = true
			var power_up = power_up_scene.instantiate()
			power_up.global_position = global_position
			power_up.rotation = Vector3(0, 0, deg_to_rad(90))
			power_up.power_up_type = GameData.power_up_types.pick_random()
			get_tree().root.add_child(power_up)
