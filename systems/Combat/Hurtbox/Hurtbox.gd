extends Area2D
class_name Hurtbox

# Hurtbox is the region that, when overlapped by a Hitbox, causes the owner to take damage

func _ready():
	monitoring = true
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	# When hitbox overlaps this hurtbox, forward damage to owner
	if area is Hitbox:
		var dmg = area.damage
		var root = get_owner()
		if root == null:
			return
		# Prefer Health component if exists
		var health_comp = root.get_node_or_null("Health")
		if health_comp:
			health_comp.take_damage(dmg)
		else:
			if root.has_method("take_damage"):
				root.take_damage(dmg)
