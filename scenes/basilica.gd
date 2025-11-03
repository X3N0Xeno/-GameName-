extends Node2D

# --- Drag your CanvasModulate node here ---
# In the scene dock, drag your 'CanvasModulate'
# node onto this variable in the Inspector.
@export var canvas_modulate: CanvasModulate
# ------------------------------------------

# This function runs when the player ENTERS the zone
func _on_dark_zone_trigger_body_entered(body):
	# Check if the body that entered is the player
	if body.is_in_group("player"):
		# Fade the scene to black
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color(0.2, 0.2, 0.2), 0.5)

# This function runs when the player LEAVES the zone
func _on_dark_zone_trigger_body_exited(body):
	# Check if the body that entered is the player
	if body.is_in_group("player"):
		# Fade back to white (normal visibility)
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color.WHITE, 0.5)
