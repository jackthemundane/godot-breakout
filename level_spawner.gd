extends Node3D

@export var brick_scene: PackedScene
@export var brick_width: float = 4.5
@export var brick_height: float = 1.5
@export var grid_offset: Vector3 = Vector3.ZERO

func spawn_level(level_data: Array) -> void:
	for child in get_children():
		child.queue_free()
	
	for row_index in level_data.size():
		var row = level_data[row_index]
		for col_index in row.size():
			var cell = row[col_index]
			if cell == 0:
				continue
			
			var brick_type = GameData.brick_map[cell]
			var brick = brick_scene.instantiate()
			brick.brick_type = brick_type
			
			var total_width = row.size() * brick_width
			var x = (col_index * brick_width) - (total_width / 2.0) + (brick_width / 2.0)
			var z = -(row_index * brick_height)
			
			brick.position = grid_offset + Vector3(x, 1, z)
			add_child(brick)
