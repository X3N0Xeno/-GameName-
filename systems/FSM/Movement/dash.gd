extends State
class_name StateDash

@export var player : Player
var dash_timer : float 
var dash_speed = 0.0
var dash_start = Vector2.ZERO


func enterState():
	dash_timer = player.dashDur
	dash_speed = player.dashDist / player.dashDur
	dash_start = player.global_position
	player.velocity = Vector2(player.last_dir * dash_speed, 0)
	player.justDashed = true

func updateState(delta : float):
	##State Implementation
	dash_timer -= delta
	#dash_speed = player.dashDist / player.dashDur
	player.velocity.x = player.last_dir * dash_speed
	player.velocity.y = 0
	
	##State Transitions
	var traveled = player.global_position.distance_to(dash_start)
	if traveled >= player.dashDist or dash_timer <= 0.0:
		if player.is_on_floor():
			transition.emit(self, "Idle")
		else:
			transition.emit(self, "Fall")
	player.move_and_slide()
