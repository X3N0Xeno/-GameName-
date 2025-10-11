extends State
class_name  StateFall

@export var player : Player
@onready var coyoteTimer : Timer = $CoyoteTimer


func enterState():
	player.isFalling = true
	coyoteTimer.start()

func updateState(_delta : float):
	##State Implementation
	#Movement whilst falling
	if player.direction:
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, player.ACCELERATION)
	
	##State Transitions
	#Ground
	if player.is_on_floor():
		if player.direction:
			transition.emit(self, "Run")
		else:
			#Reinitialize variables to default when player touches ground
			transition.emit(self, "Idle")
	
	#Air
	else:
		#Implement double jump
		if Input.is_action_just_pressed("jump") and player.hasDoubJump and player.jump_ctr <= 1:
			print("In Fall State: Double Jump")
			player.jump_ctr+=1 #Prevents infinite jumping
			transition.emit(self, "Jump")
	
	#Dash
	if Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")
	
	#WallSlide
	if player.is_on_wall():
		transition.emit(self, "WallSlide")
	player.move_and_slide()

func _on_coyote_timer_timeout() -> void:
	player.canCoyote = false
