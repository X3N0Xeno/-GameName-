extends State
class_name StateWallJump

@export var player : CharacterBody2D
var dir : int = 1

#fix wall jump
#make it so you can walljump up on 1 wall
#fix errors in transitions wallslide-run and many others caused by leaning on a wall
#fix jump errors
#change gravity and wall force
#maybe add a separate thing for upwards velocity jump

func enterState():
	if player.is_on_wall():
		dir = sign(player.get_wall_normal().x)
	else:
		dir = player.facing_dir
	player.isFalling = false
	player.velocity.y = player.wallForce * -1
	player.jump_ctr += 1
	player.canCoyote = false

func updateState(_delta : float):
	player.velocity.x = player.wallForce*1.5 * dir
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.3
	elif Input.is_action_just_pressed("dash") and player.justDashed == false and player.hasDash:
		transition.emit(self, "Dash")
	
	if Input.is_action_just_pressed("jump") and player.hasDoubJump and player.jump_ctr < 2:
		transition.emit(self, "jump")
	
	if player.is_on_ceiling():
			player.velocity.y = 1
	
	if player.velocity.y > 0 and !player.is_on_floor():
		transition.emit(self, "Fall")
	elif Input.is_action_just_pressed("mov_left") or Input.is_action_just_pressed("mov_right") and not player.is_on_wall():
		transition.emit(self, "Run")
	
	player.move_and_slide()
