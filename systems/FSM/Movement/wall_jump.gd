extends State
class_name StateWallJump

@export var player : Player
var dir : int = 1

func enterState():
	if player.is_on_wall():
		dir = sign(player.get_wall_normal().x)
	else:
		dir = player.facing_direction.x
	player.isFalling = false
	player.velocity.y = player.wallForceY * -1
	
	player.jump_ctr += 1
	player.canCoyote = false

func updateState(_delta : float):
	##State Implementation
	#Movement x
	player.velocity.x = player.wallForceX * 1.5 * dir
	
	#Movement [Directional]
	if player.direction:
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, player.ACCELERATION)
	
	#Variable Jump Height
	if (Input.is_action_just_released("jump") and player.velocity.y < 0):
		player.velocity.y *= 0.3
	
	#Ceiling Bump
	if player.is_on_ceiling():
		player.velocity.y = 1
	
	##State Transitions
	
	#Dash
	if Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		player.last_dir *= -1
		transition.emit(self, "Dash")
	
	#Double Jump
	if Input.is_action_just_pressed("jump") and player.hasDoubJump and player.jump_ctr < 2:
		print("In Wall Jump State: Double Jump")
		transition.emit(self, "jump")
	
	#Fall
	if player.velocity.y > 0 and !player.is_on_floor():
		transition.emit(self, "Fall")
	player.move_and_slide()
