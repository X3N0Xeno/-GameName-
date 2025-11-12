extends State

@export var player: Player
@onready var anim_sprite = $"../../AnimatedSprite2D"

func enterState():
	anim_sprite.play("land")
	anim_sprite.flip_h = (player.last_dir < 0)
	
	# In the Godot editor, make sure this animation's "Loop" is OFF.

func updateState(_delta):
	# 1. Check for movement input
	if player.direction:
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, player.ACCELERATION)
	
	# 2. Flip the sprite if direction changes
	if player.direction != 0:
		anim_sprite.flip_h = (player.last_dir < 0)
		
	# 3. Allow the player to "cancel" the land animation with a jump
	if Input.is_action_just_pressed("jump"):
		transition.emit(self, "Jump")

	# --- THIS IS THE FIX ---
	# You were missing this line!
	player.move_and_slide()
	# ---------------------

func _on_animation_finished():
	if player.direction != 0:
		transition.emit(self, "Run")
	else:
		transition.emit(self, "Idle")
