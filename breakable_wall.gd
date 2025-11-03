extends StaticBody2D

# This function is connected from the Area2D's 'area_entered' signal
func _on_hitbox_area_entered(area):
	# We assume your player's attack (sword, etc.) is in a group called "player_attack"
	if area.is_in_group("player_attack"):
		
		# 1. Play a breaking sound and spawn particles (optional but cool)
		# $AudioStreamPlayer.play()
		# $Particles.emitting = true
		
		# 2. Destroy the wall
		queue_free()
