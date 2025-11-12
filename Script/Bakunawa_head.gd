extends CharacterBody2D

func _ready() -> void:
	var area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func take_damage(damage: int, source_pos: Vector2) -> void:
	var parent = get_parent()
	if not parent:
		return

	# Relay damage and source to parent
	if parent.has_method("take_damage"):
		parent.take_damage(damage, source_pos)

##COMBAT SYSTEM CODE
func get_damage() -> int:
	return 1


func _on_area_2d_body_entered(body: Node) -> void:
	if not body or body == self:
		return

	# Detect if player or player-related hitbox
	if body.name == "HK" or body.is_in_group("player"):
		print("[Bakunawa] Hit:", body.name)
