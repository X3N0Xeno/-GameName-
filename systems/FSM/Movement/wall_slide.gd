extends State
class_name StateWallSlide

@export var player : Player

func enterState():
	player.isFalling = false
	player.jump_ctr = 0
	player.canCoyote = true
	player.justDashed = false

func updateState(_delta : float):
	##State Implementation
	player.velocity.y = player.wallGravity
	
	##State Transitions
	
	#Ground
	if player.is_on_floor():
		if not player.is_on_wall():
			transition.emit(self, "Idle")
	
	#Transition to Fall when player presses the direction opposite of the wall
	var wall_normal = player.get_wall_normal()
	if wall_normal != Vector2.ZERO:
		# Wall on left means normal.x = 1, so pressing right (dir = 1) is away
		if player.direction != 0 and sign(player.direction) == sign(wall_normal.x):
			transition.emit(self, "Fall")
	
	#If player is on a wall then...
	if Input.is_action_just_pressed("jump"):
		transition.emit(self, "WallJump")
	elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")
	
	player.move_and_slide()
