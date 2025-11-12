extends StaticBody2D

# This creates a dropdown in the Inspector
enum WallType { LIGHT, HEAVY }

# We export the enum to choose the wall's type.
# By default, all walls you make will be "Light".
@export var wall_type: WallType = WallType.LIGHT

# This function is called by your sword's Hitbox
func take_damage(_damage : int):
	print("LAKAD MATATAAAAAAAG")
	# Check which type of wall this is
	match wall_type:

		WallType.LIGHT:
			# Light walls always break.
			# 1. Find the camera
			var camera = get_tree().get_first_node_in_group("camera")

			# 2. If we found it, call its 'shake' function
			if camera and camera.has_method("shake"):
				camera.shake(0.2, 10.0) # (duration, strength)

			# 3. Now destroy the wall
			print("Light wall broken!")
			queue_free()

		WallType.HEAVY:
			# Heavy walls only break if the player has the upgrade.
			if PortalManager.can_break_heavy_walls:
				# 1. Find the camera
				var camera = get_tree().get_first_node_in_group("camera")

				# 2. If we found it, call its 'shake' function
				if camera and camera.has_method("shake"):
					camera.shake(0.2, 10.0) # (duration, strength)
				print("Heavy wall broken!")
				queue_free()
			else:
				# Player hit it, but doesn't have the upgrade.
				print("Wall is too strong!")
				# (This is where you would play a "Clink!" sound)
				# $ClinkSound.play()
