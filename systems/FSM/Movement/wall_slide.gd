extends State
class_name StateWallSlide

@export var player : CharacterBody2D

func enterState():
	pass

func updateState(_delta : float):
	player.velocity.y = player.wallGravity
	
	if Input.is_action_pressed("mov_left") or Input.is_action_pressed("mov_right") and not player.is_on_wall():
		transition.emit(self, "Run") 
	
	if Input.is_action_just_pressed("jump"):
		transition.emit(self, "WallJump")
	#elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		#transition.emit(self, "Dash")
	
	if player.is_on_floor() and not player.is_on_wall():
		transition.emit(self, "Idle")
	
	player.move_and_slide()
