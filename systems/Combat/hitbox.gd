class_name Hitbox
extends Area2D

var attack_damage: int = 0

func _on_area_entered(area: Area2D) -> void:
	print("something hit")
	if area.has_method("take_damage"):
		var attacker_pos = get_parent().global_position
		area.take_damage(get_parent().get_damage(), attacker_pos)
