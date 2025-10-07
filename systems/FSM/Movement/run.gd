extends State
class_name StateRun

@export var player : Player

func enterState():
	
	#player.isFalling = false
	pass

func updateState(_delta : float):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if player.direction:
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, player.ACCELERATION)
		#direction * player.SPEED
	else:
		if player.velocity.y > 1:
			transition.emit(self, "Fall")
			
	if player.is_on_floor():
		player.justDashed = false
		if player.velocity.length() <= .1 and not (Input.is_action_pressed("mov_left") or Input.is_action_pressed("mov_right")):
			transition.emit(self, "Idle")
	else:
		player.isFalling = true

	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor():
			player.jump_ctr = 0
			transition.emit(self, "Jump")
			
		#Implement double jump
		elif player.hasDoubJump and player.jump_ctr <= 1:
			player.jump_ctr+=1 #Prevents infinite jumping
			transition.emit(self, "Jump")
			
	elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")


	player.move_and_slide()
