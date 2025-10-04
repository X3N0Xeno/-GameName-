extends State
class_name  StateFall

@export var player : Player
@onready var coyoteTimer : Timer = $CoyoteTimer


func enterState():
	coyoteTimer.start()

func updateState(_delta : float):
	if Input.is_action_pressed("mov_left") or Input.is_action_pressed("mov_right"):
		transition.emit(self, "Run")
	elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")
	
	if player.is_on_floor():
		#Reinitialize variables to default when player touches ground
		transition.emit(self, "Idle")
	else:
		#if Input.is_action_just_pressed("jump") and player.canCoyote:
			#transition.emit(self, "Jump")
		#Implement double jump
		if Input.is_action_just_pressed("jump") and player.hasDoubJump and player.jump_ctr <= 1:
			#print("Player State Fall: double jumped")
			player.jump_ctr+=1 #Prevents infinite jumping
			transition.emit(self, "Jump")
	player.move_and_slide()

func _on_coyote_timer_timeout() -> void:
	player.canCoyote = false
