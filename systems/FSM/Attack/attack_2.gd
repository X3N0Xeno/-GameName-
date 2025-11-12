extends State
class_name StateAttack2

@export var player : Player
@onready var cooldown : Timer = $Cooldown

func enterState():
	cooldown.wait_time = player.cooldown_time
	cooldown.start()

func updateState(_delta : float):
	pass

func _on_cooldown_timeout() -> void:
	#print("From Attack2 State: Cooldown reached transitioning to Idle")
	transition.emit(self, "AttackIdle")
