extends AnimatableBody3D

@export var speed: float = 30.0

func _physics_process(delta: float) -> void:
	# Get the horizontal input (-1 for left, 1 for right)
	var direction = Input.get_axis("move_left", "move_right")
	
	# Calculate how far to move this specific frame
	var movement = Vector3(direction * speed * delta, 0, 0)
	
	# move_and_collide will stop the paddle if it hits a StaticBody (wall)
	# but because it's "Animatable," it will push the RigidBody (ball) 
	# with infinite force without being moved back itself.
	move_and_collide(movement)
