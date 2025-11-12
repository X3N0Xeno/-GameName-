extends CharacterBody2D

# Constants 
const GRAVITY = 300.0
const SPEED = 30.0
const CHARGE_MULTIPLIER = 2.0 
const DETECTION_RANGE = 100.0
const JUMP_DISTANCE = 40.0      # how close horizontally before pounce triggers
const JUMP_FORCE = -40.0  
const POUNCE_SPEED = 150.0      # faster forward speed when pouncing
const max_hp = 30


# References
@onready var player = $"../../Player" # Adjust path as needed
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var knockback_force: float = 200.0
@export var knockback_duration: float = 0.3
@export var KNOCKBACK_FORCE: float = 100.0
@export var KNOCKBACK_TIME: float = 0.2
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knocked_back := false
var hp
var can_jump := true             # prevents repeated pounces in the air

func _ready() -> void:
	hp = max_hp
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
		can_jump = true  # reset pounce ability when touching ground

	if not is_knocked_back:
		if player and global_position.distance_to(player.global_position) <= DETECTION_RANGE:
			var dir_to_player = (player.global_position - global_position).normalized()

			#Pounce behavior
			if can_jump and abs(player.global_position.x - global_position.x) <= JUMP_DISTANCE and is_on_floor():
				velocity.y = JUMP_FORCE
				velocity.x = dir_to_player.x * POUNCE_SPEED
				can_jump = false
			else:
				# Normal chase toward player
				velocity.x = dir_to_player.x * SPEED * CHARGE_MULTIPLIER
		else:
			#Idle (stand still) when outside detection range
			velocity.x = 0
	else:
		# Knockback deceleration
		velocity = velocity.move_toward(Vector2.ZERO, 1000 * delta)
	# --- Knockback handling ---
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		if knockback_timer <= 0:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return
	# Apply movement
	move_and_slide()

	# Flip sprite
	if not is_knocked_back and velocity.x != 0:
		sprite.flip_h = velocity.x > 0

func take_damage(amount: int, source_pos: Vector2) -> void:
	hp -= amount
	print("Chanak HP:", hp)

	if hp <= 0:
		queue_free()
		return

	var knock_dir = (global_position - source_pos).normalized()
	knockback_velocity = knock_dir * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_TIME
	is_knocked_back = true

##COMBAT SYSTEM CODE
func get_damage() -> int:
	return 1
