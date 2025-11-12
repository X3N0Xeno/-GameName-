extends Node2D
class_name BaseWeapon

@export var attack_damage: int = 10
@export var attack_duration: float = 0.2
@export var cooldown: float = 0.5

# --- NEW VARIABLE ---
# How far up/down the hitbox moves for vertical attacks
@export var vertical_attack_offset: float = 12.0

var can_attack: bool = true
var hitbox: Hitbox
var _cooldown_timer: Timer

# --- NEW VARIABLES ---
# To store the hitbox's default "at rest" state
var default_hitbox_pos: Vector2
var default_hitbox_rot: float
var default_hitbox_scale: Vector2

func _ready():
	if not has_node("Hitbox"):
		push_error("%s missing Hitbox child!" % name)
		return
	
	hitbox = $Hitbox
	hitbox.monitoring = false
	hitbox.attack_damage = attack_damage
	
	# --- NEW ---
	# Store the default transform of the hitbox
	default_hitbox_pos = hitbox.position
	default_hitbox_rot = hitbox.rotation
	default_hitbox_scale = hitbox.scale
	
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(_cooldown_timer)
	
	print_debug("Weapon READY: %s" % name)

# --- THIS FUNCTION IS UPDATED ---
func attack(_direction: Vector2): # Accepts a Vector2
	if not can_attack:
		print_debug("%s on cooldown" % name)
		return
	
	can_attack = false
	print_debug("%s ATTACK START" % name)
	
	# --- THIS IS THE NEW LOGIC ---
	
	# Reset rotation to default, just in case
	hitbox.rotation = default_hitbox_rot
	
	# Check if attack is mostly horizontal or vertical
	if abs(_direction.x) > abs(_direction.y):
		# --- HORIZONTAL ATTACK ---
		
		# 1. Set the scale (1 or -1) to flip the hitbox
		hitbox.scale.x = sign(_direction.x)
		hitbox.scale.y = default_hitbox_scale.y
		
		# 2. Set the position
		# This moves it to the right by default (e.g., x=6.5)
		# and then flips it to the left (x=-6.5) if direction is -1
		hitbox.position.x = default_hitbox_pos.x * sign(_direction.x)
		hitbox.position.y = default_hitbox_pos.y
		
	else:
		# --- VERTICAL ATTACK ---
		
		# 1. Reset scale to default
		hitbox.scale = default_hitbox_scale
		
		# 2. Rotate the hitbox to be vertical
		hitbox.rotation_degrees = 90
		
		if _direction.y < 0:
			# --- UP ATTACK ---
			# Set position to be centered (x=0) and just above the player
			hitbox.position = Vector2(0, -12-vertical_attack_offset)
		else:
			# --- DOWN ATTACK ---
			# Set position to be centered (x=0) and just below the player
			hitbox.position = Vector2(0, 15-vertical_attack_offset)
	# --------------------------

	# Activate hitbox
	hitbox.monitoring = true
	
	await get_tree().create_timer(attack_duration).timeout
	
	# Deactivate hitbox
	hitbox.monitoring = false
	print_debug("%s attack window closed" % name)
	
	_cooldown_timer.start(cooldown)

func _on_cooldown_timeout():
	can_attack = true
	
	# --- NEW ---
	# Reset the hitbox to its default state after cooldown
	hitbox.position = default_hitbox_pos
	hitbox.rotation = default_hitbox_rot
	hitbox.scale = default_hitbox_scale
	
	print_debug("%s ready to attack" % name)
