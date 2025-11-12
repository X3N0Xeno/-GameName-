extends State
class_name StateJump

@export var player : Player
var can_double_jump := false

func enterState():
	player.isFalling = false
	player.velocity.y = player.JUMP_DIST * -1
	player.jump_ctr += 1
	player.canCoyote = false
	
	# Add a delay before allowing double jump
	await get_tree().create_timer(0.1).timeout
	can_double_jump = true

func updateState(_delta : float):
	##State Implementation
	#Variable jump height
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.2
	
	#Ceiling Bump
	if player.is_on_ceiling():
		player.velocity.y = 1
	
	#Movement
	if player.direction:
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, player.ACCELERATION)
	
	##State Transitions
	#Dash
	if Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")
	
	#Double Jump
	if can_double_jump and Input.is_action_just_pressed("jump") and player.hasDoubJump and player.jump_ctr < 2:
		#print("In Jump State: Double Jump")
		transition.emit(self, "Jump")
	
	#Fall
	if player.velocity.y > 0 and not player.is_on_floor():
		transition.emit(self, "Fall")
	
	player.move_and_slide()
