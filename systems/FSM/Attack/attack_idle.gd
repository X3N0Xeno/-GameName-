extends State
class_name AttackIdle

@export var MOV_FSM : StateMachine
@export var player : Player
func enterState():
	pass

func updateState(_delta : float):
	if player.can_attack:
		if MOV_FSM.cur_state.name != "WallSlide" and MOV_FSM.cur_state.name != "Dash":
			if Input.is_action_just_pressed("attack"):
				if Input.is_action_pressed("look_up"): #Up Arrow Key
					transition.emit(self, "AttackUp")
				elif Input.is_action_pressed("look_down") and (MOV_FSM.cur_state.name == "Fall" or MOV_FSM.cur_state.name == "Jump"): #Down Arrow Key
					#print("From AttackIdle: Requesting attack state to change to AttackDown")
					player.can_pogo = true
					transition.emit(self, "AttackDown")
				else:
					transition.emit(self, "Attack")
