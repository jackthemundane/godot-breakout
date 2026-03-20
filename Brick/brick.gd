extends StaticBody3D

@export_enum("standard", "tough", "unbreakable") var brick_type: String = "standard"
var data: Dictionary
var health: int

func _ready() -> void:
	data = GameData.brick_types[brick_type]
	health = data["health"]
	var material = StandardMaterial3D.new()
	material.albedo_color = data["color"]
	$MeshInstance3D.material_override = material

func hit() -> void:
	if health == -1:
		return
	health -= 1
	$MeshInstance3D.material_override.albedo_color = $MeshInstance3D.material_override.albedo_color.darkened(0.4)
	if health <= 0:
		GameData.add_score(data["points"])
		print(GameData.score)
		queue_free()
