extends Node2D # Or whatever your Nuno's base node is

# This signal tells the manager "The player touched me!"
signal player_touched

func _on_Area2D_body_entered(body):
	# Check if the body is the player
	if body.is_in_group("player"):
		# Tell the manager, but don't do anything else
		print("Nuno Touched!")
		player_touched.emit()
