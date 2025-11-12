extends AnimatableBody2D

# This function will be called by your Clue Progression script
func open_gate():
	print("Altar gate is opening!")
	
	# We'll use a Tween to move it up 100 pixels over 1.5 seconds
	var tween = create_tween()
	tween.tween_property(self, "position", position - Vector2(0, 50), 1.5)
	z_index=-1
	
	# After the tween is done, disable the collision
	await tween.finished
	get_node("CollisionShape2D").disabled = true
