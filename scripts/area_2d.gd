extends Area2D

@export var start_position: Node2D

func _on_body_entered(body):
	print("A body entered the red zone. Body:", body.name)
	
	if body.is_in_group("player"):
		print("The body was the player! Teleporting...")
		body.global_position = start_position.global_position
