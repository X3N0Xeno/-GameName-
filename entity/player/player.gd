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


@onready var FSM : StateMachine = $FSM
@onready var StateLabel : Label = $DebugState

##Player wide global variables
var canCoyote : bool = true #COYOTE JUMPING FLAG IS BUGGY! FIND COYOTE JUMP LOGIC IN FALL
var jump_ctr : int = 0

func _physics_process(delta: float) -> void:
	#print("PLAYER SCRIPT DEBUG: ", canCoyote)
	StateLabel.text = FSM.cur_state.name
	friction()
	
	clamp(velocity.x, -SPEED, SPEED)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

func friction() -> void:
	var direction := Input.get_axis("mov_left", "mov_right")
	if !direction:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
		
		
## Combat Systems

@export_category("Combat")
@export var health: Health # assign Health node in the inspector or via child

func _ready():
	if health:
		health.connect("health_changed", Callable(self, "_on_health_changed"))
		health.connect("died", Callable(self, "_on_died"))
	else:
		printerr("Health node not assigned on Player")

func _on_health_changed(_old_hp: int, new_hp: int) -> void:
	# React to health change (e.g. play hit effect, flash, etc.)
	# no UI yet, so maybe just log or handle logic
	print("Player health changed to:", new_hp)

func _on_died() -> void:
	# Player death logic
	print("Player died")
	# disable further input, switch state, etc.
