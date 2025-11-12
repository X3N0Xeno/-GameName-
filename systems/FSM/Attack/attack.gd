extends State
class_name StateAttack

@export var player : Player
@onready var cooldown : Timer = $Cooldown
@onready var delay : Timer = $Delay
var justAttacked : bool = false
func enterState():
	justAttacked = false
	cooldown.wait_time = player.cooldown_time
	cooldown.start()
	
	delay.wait_time = player.attack_delay

func updateState(_delta : float):
	if Input.is_action_just_pressed("attack") and !justAttacked:
		justAttacked = true
		cooldown.stop() #Stop the AttackIdle transition
		delay.start() #Start transitioning to Attack2

func _on_cooldown_timeout() -> void:
	#print("From Attack State: Cooldown reached transitioning to Idle")
	transition.emit(self, "AttackIdle")

func _on_delay_timeout() -> void:
	transition.emit(self, "Attack2");
