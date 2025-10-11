extends State
class_name StateRun

@export var player : Player

func enterState():
	
	player.isFalling = false
	pass

func updateState(_delta : float):
	##State Implementation
	#Movement
	if player.direction:
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, player.ACCELERATION)
	
	##State Transitions
	#Ground
	if player.is_on_floor():
		player.justDashed = false
		
		#Idle
		if player.velocity.length() <= .1 and not player.direction:
			transition.emit(self, "Idle")
		
		#Jump
		elif Input.is_action_just_pressed("jump"):
			player.jump_ctr = 0
			transition.emit(self, "Jump")
		
		#Dash
		elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
			transition.emit(self, "Dash")
	#Air - Fall
	else:
		if player.velocity.y > 1 and not player.direction:
			player.isFalling = true
			transition.emit(self, "Fall")
	
	#WallSlide
	if player.is_on_wall() and not player.is_on_floor():
		#print("State Run: Player is on wall")
		transition.emit(self, "WallSlide")

	player.move_and_slide()
