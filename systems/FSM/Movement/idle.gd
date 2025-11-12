extends State
class_name StateIdle

@export var player : Player

func enterState():
	player.isFalling = false
	player.jump_ctr = 0
	player.canCoyote = true
	player.justDashed = false

func updateState(_delta : float):	
	#When Player is on ground...
	if player.is_on_floor():
		#Transition to RUN STATE when left or right button pressed
		if Input.is_action_pressed("mov_left") or Input.is_action_pressed("mov_right"):
		
		#Back in our FSM script, the change_state function needs two arguments:
		#old_state and new_state_name. It is called when the transition signal gets emitted
		#old_state is this state (Idle) which is placed as self 
		#and new_state_name, which is the name of the state you want to transition to
			transition.emit(self, "Run") 
		
		#Transition to JUMP STATE when jump button pressed
		elif Input.is_action_just_pressed("jump"):
			transition.emit(self, "Jump")
		
		#Transition to DASH STATE when jump button pressed
		elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
			transition.emit(self, "Dash")
	player.move_and_slide()
