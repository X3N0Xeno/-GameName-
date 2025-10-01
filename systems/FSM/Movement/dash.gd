extends State
class_name StateDash

@export var player : Player

func enterState():
	pass

func updateState(_delta : float):
	player.velocity.x = move_toward(player.velocity.x, player.last_dir * player.dashDist, player.dashSpeed)
	
	#Handle Fall and Idle
	if player.velocity.x >= player.dashDist or player.velocity.x <= -player.dashDist:
		if player.velocity.y > 1:
			transition.emit(self, "Fall")
		if player.is_on_floor():
			transition.emit(self, "Idle")
	
	player.move_and_slide()
