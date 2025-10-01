extends CharacterBody2D
class_name Player

@export_category("Movement")
@export var SPEED : float
@export var JUMP_VELOCITY : float
@export var JUMP_DIST : float
@export var ACCELERATION : float
@export var FRICTION : float

##THIS CATEGORY CAN BE MOVED INTO A GLOBAL SCRIPT FOR EASIER SAVING
@export_category("Power-ups")
@export var hasDoubJump : bool
@export var hasDash : bool
@export var hasWallJump : bool

@export_category("Dash Stats")
@export var	dashSpeed : float
@export var dashDist : float

@onready var FSM : StateMachine = $FSM
@onready var StateLabel : Label = $DebugState

##Player wide global variables
var canCoyote : bool = true #COYOTE JUMPING FLAG IS BUGGY! FIND COYOTE JUMP LOGIC IN FALL
var jump_ctr : int = 0
var direction : float
var last_dir : float = 1.0 #WARNING! THIS IS INITIALIZED TO 1.0 TO FORCE THE PLAYER TO FACE RIGHT

func _physics_process(delta: float) -> void:
	#print("PLAYER SCRIPT DEBUG: ", canCoyote)
	#print("PLAYER SCRIPT DEBUG: ", last_dir)
	print(velocity.x)
	StateLabel.text = FSM.cur_state.name
	friction()
	
	clamp(velocity.x, -SPEED, SPEED)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

func friction() -> void:
	direction = Input.get_axis("mov_left", "mov_right")
	if !direction:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else:
		last_dir = direction
