extends Camera2D

# --- Drag your Player node here ---
@export var player: Node2D

# We'll use this to toggle following
var is_following := true

# We'll use this to make the follow feel smooth
@export var follow_speed: float = 5.0

func _process(delta):
	# If we are supposed to be following, smoothly move to the player
	if is_following and player:
		# lerp gives it a nice, smooth camera dampening
		global_position = global_position.lerp(player.global_position, 1.0 - exp(-delta * follow_speed))

# This is the function our BossManager will call
func focus_on_arena(arena_position, new_zoom_vector):
	is_following = false
	
	# Use a Tween to smoothly move the camera
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Tween position and zoom at the same time
	tween.parallel().tween_property(self, "global_position", arena_position, 1.0) # 1.0-second tween
	tween.parallel().tween_property(self, "zoom", new_zoom_vector, 1.0)

# This is the other function our BossManager will call
func resume_following_player(original_zoom_vector):
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Tween back to the player's position and original zoom
	tween.parallel().tween_property(self, "global_position", player.global_position, 1.0)
	tween.parallel().tween_property(self, "zoom", original_zoom_vector, 1.0)
	
	# Wait for the tween to finish, *then* resume following
	await tween.finished
	is_following = true
