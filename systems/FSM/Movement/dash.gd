extends State
class_name StateDash

@export var player : Player
var dash_timer : float 


func enterState():
	player.justDashed = true
	dash_timer = player.dashDur

func updateState(delta : float):
	dash_timer -= delta
	var dash_speed = player.dashDist / player.dashDur
	player.velocity.x = player.last_dir * dash_speed
	player.velocity.y = 0
	if dash_timer <= 0.0:
		#Handle Fall and Idle
		if player.is_on_floor():
			transition.emit(self, "Idle")
		else :
			#player.velocity.y > 1
			transition.emit(self, "Fall")
	player.move_and_slide()
