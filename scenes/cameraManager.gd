extends Camera2D

# --- Existing Variables ---
@export var player: Node2D
var is_following := true
@export var follow_speed: float = 5.0

# --- Shake Variables ---
var _shake_timer := Timer.new()
var _shake_strength: float = 0.0
# ---------------------------


func _ready():
	# --- Setup the shake timer ---
	_shake_timer.one_shot = true
	_shake_timer.timeout.connect(_on_shake_timeout)
	add_child(_shake_timer)
	# --------------------------------


func _process(delta):
	# --- Follow Logic (UPDATED) ---
	if is_following and player:
		
		# --- THIS IS THE FIX ---
		# 1. Define a target position that is slightly above the player
		var target_position = player.global_position + Vector2(0, -28)
		
		# 2. Lerp to the new target position instead of the player's direct position
		global_position = global_position.lerp(target_position, 1.0 - exp(-delta * follow_speed))
	
	# --- Shake Logic (runs in parallel) ---
	if _shake_timer.is_stopped():
		offset = Vector2.ZERO # No shake
	else:
		# Get the timer's progress (1.0 at start, 0.0 at end)
		var remaining = _shake_timer.time_left / _shake_timer.wait_time
		# Use 'powi(2)' to make it fade out fast (strong start, quick end)
		var dampen_factor = pow(remaining, 2)
		
		# Generate a random direction
		var rand_x = randf_range(-1.0, 1.0)
		var rand_y = randf_range(-1.0, 1.0)
		
		# Apply the offset, multiplied by the strength and fade-out
		# The camera's final position will be its global_position + this offset
		offset = Vector2(rand_x, rand_y) * _shake_strength * dampen_factor
	# ------------------------------------

# --- Existing Boss Functions ---
func focus_on_arena(arena_position, new_zoom_vector):
	is_following = false
	
	# Use a Tween to smoothly move the camera
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Tween position and zoom at the same time
	tween.parallel().tween_property(self, "global_position", arena_position, 1.0) # 1.0-second tween
	tween.parallel().tween_property(self, "zoom", new_zoom_vector, 1.0)

func resume_following_player(original_zoom_vector):
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Tween back to the player's position and original zoom
	tween.parallel().tween_property(self, "global_position", player.global_position, 1.0)
	tween.parallel().tween_property(self, "zoom", original_zoom_vector, 1.0)
	
	# Wait for the tween to finish, *then* resume following
	await tween.finished
	is_following = true

# --- Shake Functions ---
func shake(duration: float = 0.2, strength: float = 8.0):
	_shake_strength = strength
	_shake_timer.wait_time = duration
	_shake_timer.start()
	
func _on_shake_timeout():
	# Just in case, set offset back to zero when timer ends
	offset = Vector2.ZERO
