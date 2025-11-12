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

@export_category("Wall Jump Stats")
@export var wallGravity : float
@export var wallForceY : float
@export var wallForceX : float

@export_category("HP Related")
@export var HP : int
@export var heal_amount : int
@export var hits_to_heal : int

@export_category("Attack Stats")
@export_enum("DMG_Sword1", "DMG_Sword2", "DMG_Sword3") 
var sword : String = "DMG_Sword1"
@export var DMG_Sword1 : int = 9 ##MUSEUM SWORD DAMAGE
@export var DMG_Sword2 : int = 14 ##LAPU-LAPU SWORD DAMAGE
@export var DMG_Sword3 : int = 24 ##HOLY SWORD DAMAGE
@export var cooldown_time : float ##How long until it transitions to AttackIdle [be able to attack again]. Note that Attack1 -> Attack2 uses the below variable.
@export var attack_delay : float ##The delay between combo attacks. In this case, Attack1 -> Attack2 states.
var cur_damage : int
var hits : int = 0

@onready var FSM : StateMachine = $MOV_FSM
@onready var ATK_FSM : StateMachine = $ATK_FSM
@onready var StateLabel : Label = $DebugState
@onready var StateLabel2 : Label = $DebugState2

##Player wide global variables
var canCoyote : bool = true #COYOTE JUMPING FLAG IS BUGGY! FIND COYOTE JUMP LOGIC IN FALL
var isFalling : bool = false
var jump_ctr : int = 0
var justDashed : bool = false
var direction : float
var last_dir : float = 1.0 #WARNING! THIS IS INITIALIZED TO 1.0 TO FORCE THE PLAYER TO FACE RIGHT
var current_health: int = 100

var facing_direction = Vector2.RIGHT  # Track which way player is facing

#For ATK_FSM
var can_pogo : bool = false
var can_attack: bool = false # Player starts unable to attack
##Testing
var max_velx : float = 0.0

func _physics_process(delta: float) -> void:	
	if last_dir == 1:
		if max_velx < velocity.x:
			max_velx = velocity.x
	else:
		if -max_velx > velocity.x:
			max_velx = velocity.x
	StateLabel.text = FSM.cur_state.name
	StateLabel2.text = ATK_FSM.cur_state.name
	friction()
	
	clamp(velocity.x, -SPEED, SPEED)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if isFalling:
			velocity.y += GRAVITY*1.5 * delta
	
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
		
	# Update facing direction based on input or velocity
	var input_dir = Input.get_vector("mov_left", "mov_right", "look_up", "look_down")
	if input_dir.length() > 0:
		facing_direction = input_dir

func friction() -> void:
	direction = Input.get_axis("mov_left", "mov_right")
	if !direction:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else:
		last_dir = direction

func _ready():
	hasDash = PortalManager.has_dash_upgrade
	can_attack = PortalManager.has_attack_upgrade
	current_health = max_health
	print("Player health initialized: %d" % current_health)
	add_to_group("player")
	save_pos()

##COMBAT SYSTEM CODE
func get_damage() -> int:
	match sword:
		"DMG_Sword1":
			cur_damage = DMG_Sword1
		"DMG_Sword2":
			cur_damage = DMG_Sword2
		"DMG_Sword3":
			cur_damage = DMG_Sword3
	return cur_damage

func take_damage(damage: int):
	HP -= damage
	print("Player took ", damage, " damage, health is now ", HP)
	if HP <= 0:
		die()

#WARNING ADD CUSTOM DEATH CODE. QUEUE FREE? TELEPORT TO LAST BABAYLAN?
func die():
	print("Player has died!")

func heal():
	if hits >= hits_to_heal: #If hits threshold is met
		HP += heal_amount #heal Y amount
		hits = 0 #Reset hits
		print("PLAYER HEAL() DEBUG: Healed for " , heal_amount, " HP now ", HP ," hits reset back to " , hits)
	else:
		print("PLAYER HEAL() DEBUG: Tried healing. hits not yet in threshold. Still at ", hits , " hits out of " , hits_to_heal)

#This is for healing
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemy"):
		hits += 1
		heal()

##PLAYER POSITION WHEN SAVING AND / OR USING PORTALS
func save_pos():

	# --- PRIORITY 1: CHECK FOR SAVE GAME LOAD ---
	var loaded_position = SaveManager.get_pending_load_position()
	if loaded_position != Vector2.ZERO:
		print("Player: Loading from save file.")
		global_position = loaded_position
		return # Stop here.

	# --- PRIORITY 2: CHECK FOR A LEVEL TRANSITION ---
	var spawn_name = PortalManager.next_spawn_point_name
	if not spawn_name.is_empty():
		var spawn_point = get_tree().current_scene.find_child(spawn_name, true, false)
		if spawn_point:
			print("Player: Spawning at level transition '", spawn_name, "'")
			global_position = spawn_point.global_position
		else:
			print("Player WARNING: Could not find spawn point '", spawn_name, "'! Using default.")
		PortalManager.next_spawn_point_name = "" # Clear the flag
		return # Stop here.

	# --- PRIORITY 3: CHECK FOR PUZZLE RETURN (THE FIX) ---
	var puzzle_return_scene = PortalManager.puzzle_return_scene_path
	var puzzle_return_pos = PortalManager.puzzle_return_position
	var current_scene_filename = get_tree().current_scene.scene_file_path.get_file()

	if not puzzle_return_scene.is_empty() and current_scene_filename == puzzle_return_scene.get_file():
		print("Player: Returning from puzzle.")
		global_position = puzzle_return_pos

		# Clear the flags
		PortalManager.puzzle_return_scene_path = ""
		PortalManager.puzzle_return_position = Vector2.ZERO
		return # Stop here.
	# --------------------------------------------------

	# --- PRIORITY 4: CHECK FOR NUNO PORTAL RETURN ---
	var return_scene_path = PortalManager.return_scene_path
	var return_position = PortalManager.return_position
	var return_scene_filename = return_scene_path.get_file()

	if not return_scene_path.is_empty() and current_scene_filename == return_scene_filename:
		print("Player: Returning from Nuno portal.") 
		global_position = return_position
		PortalManager.return_scene_path = ""
		PortalManager.return_position = Vector2.ZERO
		PortalManager.just_returned_from_portal = true
		return # Stop here.

	# --- PRIORITY 5: NATURAL SCENE ENTRY ---
	# If none of the above, we're just entering the scene normally.
	print("Player: Entering ", current_scene_filename, " naturally. Re-enabling systems.")
	PortalManager.re_enable_all_portals()
	PortalManager.re_enable_all_arenas()
	PortalManager.re_enable_all_puzzles() # <-- ADD THIS
