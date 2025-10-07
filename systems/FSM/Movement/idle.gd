extends State
class_name StateIdle

@export var player : Player

func enterState():
	player.jump_ctr = 0
	player.canCoyote = true

func updateState(_delta : float):
	#Transition to Run State when left or right button pressed
	if Input.is_action_pressed("mov_left") or Input.is_action_pressed("mov_right"):
		
		#Back in our FSM script, the change_state function needs two arguments:
		#old_state and new_state_name. It is called when the transition signal gets emitted
		#old_state is this state (Idle) which is placed as self 
		#and new_state_name, which is the name of the state you want to transition to
		transition.emit(self, "Run") 
	
	# Handle jump.
	elif Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition.emit(self, "Jump")
	
	#Handle dash.
	elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")
	player.move_and_slide()
