extends CharacterBody2D

# ======================
# CONFIGURATION
# ======================
const GRAVITY = 100.0
const SPEED = 100.0
const CHARGE_MULTIPLIER = 2.0
const MAX_FALL_SPEED = 300.0
const CHARGE_RANGE = 400.0
const WANDER_CHANGE_INTERVAL = 2.0  # seconds to change patrol direction

const max_hp = 3
@onready var player = $"../../HK"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# ======================
# STATE VARIABLES
# ======================
var hp: int
var wander_direction: int = 0  # -1 left, 0 idle, 1 right
var wander_timer: float = 0.0

func _ready() -> void:
	hp = max_hp
	sprite.play("walk")
	_set_new_wander_direction()

func _physics_process(delta: float) -> void:
	if not player:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	else:
		velocity.y = 0

	# Distance to player
	var dir_to_player = (player.global_position - global_position).normalized()
	var dist = global_position.distance_to(player.global_position)

	var target_speed: float

	if dist < CHARGE_RANGE:
		# --- Chase player ---
		target_speed = SPEED * CHARGE_MULTIPLIER * dir_to_player.x
	else:
		# --- Wander / patrol ---
		wander_timer -= delta
		if wander_timer <= 0:
			_set_new_wander_direction()
		target_speed = SPEED * 0.5 * wander_direction  # slower patrol

	# Smooth horizontal movement
	velocity.x = lerp(float(velocity.x), float(target_speed), 0.05)

	# Flip sprite
	if abs(velocity.x) > 0.1:
		sprite.flip_h = velocity.x < 0

	move_and_slide()

# ======================
# WANDER LOGIC
# ======================
func _set_new_wander_direction() -> void:
	wander_direction = randi() % 3 - 1  # -1, 0, 1
	wander_timer = WANDER_CHANGE_INTERVAL

# ======================
# DEBUG DAMAGE INPUT
# ======================
func take_damage(amount: int) -> void:
	hp -= amount
	print("Zombie HP:", hp)
	if hp <= 0:
		queue_free()
