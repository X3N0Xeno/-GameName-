extends State
class_name StateRun

@export var player : Player

func enterState():
	pass

func updateState(_delta : float):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("mov_left", "mov_right")
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction * player.SPEED, player.ACCELERATION)
		#direction * player.SPEED
	else:
		if player.velocity.y > 1:
			transition.emit(self, "Fall")
	
	
<<<<<<< HEAD
	if player.velocity.length() <= .1 and player.is_on_floor():
		transition.emit(self, "Idle")
	
=======
	if player.is_on_floor():
		player.justDashed = false
		if player.velocity.length() <= .1:
			transition.emit(self, "Idle")

>>>>>>> parent of 31aae2b (Merge pull request #3 from X3N0Xeno/player-movement)
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor():
			player.jump_ctr = 0
			transition.emit(self, "Jump")
			
		#Implement double jump
		elif player.hasDoubJump and player.jump_ctr <= 1:
			player.jump_ctr+=1 #Prevents infinite jumping
			transition.emit(self, "Jump")


	player.move_and_slide()
