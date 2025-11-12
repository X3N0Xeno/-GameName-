extends Area2D

func take_damage(damage: int, source_pos: Vector2) -> void:
	var parent = get_parent()
	if not parent:
		return

	if parent.has_method("take_damage"):
		var callable = Callable(parent, "take_damage")
		var arg_count = callable.get_argument_count()

		if arg_count == 2:
			parent.take_damage(damage, source_pos)
		else:
			parent.take_damage(damage)
