extends CharacterBody2D
class_name Player

@export_category("Movement")
@export var GRAVITY : float
@export var MAX_FALL_SPEED : float
@export var SPEED : float
#@export var JUMP_VELOCITY : float = 1000.0
@export var JUMP_DIST : float
@export var ACCELERATION : float
@export var FRICTION : float
@export var max_health: int 

##THIS CATEGORY CAN BE MOVED INTO A GLOBAL SCRIPT FOR EASIER SAVING
@export_category("Power-ups")
@export var hasDoubJump : bool
@export var hasDash : bool
@export var hasWallJump : bool

@export_category("Dash Stats")
@export var	dashDist : float
@export var dashDur : float

@onready var FSM : StateMachine = $FSM
@onready var StateLabel : Label = $DebugState

##Player wide global variables
var canCoyote : bool = true #COYOTE JUMPING FLAG IS BUGGY! FIND COYOTE JUMP LOGIC IN FALL
var isFalling : bool = false
var jump_ctr : int = 0
var justDashed : bool = false
var direction : float
var last_dir : float = 1.0 #WARNING! THIS IS INITIALIZED TO 1.0 TO FORCE THE PLAYER TO FACE RIGHT
var current_health: int = 100
##Testing
var max_velx : float = 0.0

func _physics_process(delta: float) -> void:
	
	#print("PLAYER SCRIPT DEBUG: ", canCoyote)
	#print("PLAYER SCRIPT DEBUG: ", last_dir)
	#print("PLAYER SCRIPT DEBUG: ", velocity.y)
	
	if last_dir == 1:
		if max_velx < velocity.x:
			max_velx = velocity.x
	else:
		if -max_velx > velocity.x:
			max_velx = velocity.x
		
	
	StateLabel.text = FSM.cur_state.name
	friction()
	
	clamp(velocity.x, -SPEED, SPEED)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if isFalling:
			velocity.y += GRAVITY*1.5 * delta
	
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

func friction() -> void:
	direction = Input.get_axis("mov_left", "mov_right")
	if !direction:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else:
		last_dir = direction
		
		
## DO NOT TOUCH THIS STUFF IS FOR ANIMATION USING ANIMATED SPRITES
#const DEFAULT_WEAPON = preload("res://new-scenes/sword_1.tscn")
#
#@onready var weapon_holder := $WeaponHolder
#@onready var upper_body = $AnimatedSprite2D
#
#var current_weapon: BaseWeapon
#var facing_direction = Vector2.RIGHT  # Track which way player is facing
#
#func _ready():
	#current_health = max_health
	#print_debug("Player health initialized: %d" % current_health)
	#equip_weapon(DEFAULT_WEAPON)
#
#func _input(event):
	#if event.is_action_pressed("attack"):
		#if current_weapon and is_instance_valid(current_weapon):
			#play_attack_animation()
	#current_weapon.attack()
##
##func play_attack_animation():
	### Determine attack direction based on facing_direction
	##if abs(facing_direction.x) > abs(facing_direction.y):
	### Horizontal attack
		##if facing_direction.x > 0:
			##upper_body.play("attack_side1")
			##upper_body.flip_h = false
		##else:
			##upper_body.play("attack_side2")
			##upper_body.flip_h = true
	##else:
	### Vertical attack
			##if facing_direction.y < 0:
				##upper_body.play("attack_up")
			##else:
				##upper_body.play("attack_down")
##
##func _physics_process1(_delta):
	### Update facing direction based on input or velocity
	##var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	##if input_dir.length() > 0:
		##facing_direction = input_dir
##
##func equip_weapon(weapon_scene: PackedScene):
	##if current_weapon and is_instance_valid(current_weapon):
		##current_weapon.queue_free()
		##
	##current_weapon = weapon_scene.instantiate()
	##weapon_holder.add_child(current_weapon)
	##print_debug("Equipped: %s" % current_weapon.name)


## HEALTH - I GUESS I SHOULD ADD AN HEALTHBAR

func take_damage(amount: int):
	current_health -= amount
	print_debug("Player took %d damage! Current HP: %d" % [amount, current_health])
	if current_health <= 0:
		die()

func die():
	print_debug("Player has died!")
