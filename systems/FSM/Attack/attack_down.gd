extends State
class_name StateAttackDown

@export var player : Player
@export var MOV_FSM : StateMachine
@export var PARENT_FSM : StateMachine
@onready var cooldown : Timer = $Cooldown

func enterState():
	cooldown.wait_time = 0.1
	cooldown.start()

func updateState(_delta : float):
	pass

func _on_cooldown_timeout() -> void:
	#print("From Attack State: Cooldown reached transitioning to Idle")
	transition.emit(self, "AttackIdle")

func _on_hitbox_area_entered(_area: Area2D) -> void:
	if player.can_pogo:
		player.justDashed = false #Reset the dash
		player.jump_ctr = 0 #Reset the jump
		MOV_FSM.force_change_state("Jump")
