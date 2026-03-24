extends Area3D

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("active_balls"):
		body.remove_from_group("active_balls")
		var remaining = get_tree().get_nodes_in_group("active_balls").size()
		if remaining == 0:
			GameData.lose_life()
			var original = get_node_or_null("/root/Main/Ball")
			if original:
				original.visible = true
				original.reset()
			if body != original:
				body.queue_free()
		else:
			if body == get_node_or_null("/root/Main/Ball"):
				body.freeze = true
				body.visible = false
				body.linear_velocity = Vector3.ZERO
			else:
				body.queue_free()
