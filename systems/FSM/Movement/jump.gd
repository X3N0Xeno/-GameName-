extends State
class_name StateJump

@export var player : Player

func enterState():
	player.jump_ctr += 1
	player.canCoyote = false

func updateState(_delta : float):
	player.velocity.y = move_toward(0, player.JUMP_DIST * -1, player.JUMP_VELOCITY)
	player.move_and_slide()
	transition.emit(self, "Fall")
