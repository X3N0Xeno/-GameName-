extends State
class_name StateJump

@export var player : Player

func enterState():
	#player.velocity.y = sqrt(2 * player.get_gravity().y * player.JUMP_DIST)
	player.isFalling = false
	player.velocity.y = player.JUMP_DIST * -1
	player.jump_ctr += 1
	player.canCoyote = false

func updateState(_delta : float):
	#Variable jump height
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.3
	elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")
	
	if Input.is_action_just_pressed("jump") and player.hasDoubJump and player.jump_ctr < 2:
		transition.emit(self, "jump")
	
	if player.is_on_ceiling():
			player.velocity.y = 1
	
	if player.velocity.y > 0 and !player.is_on_floor():
		transition.emit(self, "Fall")
	elif Input.is_action_just_pressed("mov_left") or Input.is_action_just_pressed("mov_right"):
		transition.emit(self, "Run")
	
	if player.is_on_wall():
		#print("State Jump: Player is on wall")
		transition.emit(self, "WallSlide")
	
	player.move_and_slide()
