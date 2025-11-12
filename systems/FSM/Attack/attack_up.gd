extends State
class_name StateAttackUp

@export var player : Player
@onready var cooldown : Timer = $Cooldown

func enterState():
	cooldown.wait_time = player.cooldown_time
	cooldown.start()

func updateState(_delta : float):
	#if Input.is_action_just_pressed("attack"):
		#cooldown.stop()
		#transition.emit(self, "Attack2");
		pass

func _on_cooldown_timeout() -> void:
	#print("From Attack State: Cooldown reached transitioning to Idle")
	transition.emit(self, "AttackIdle")
