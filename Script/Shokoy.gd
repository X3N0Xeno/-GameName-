extends CharacterBody2D

# CONFIGURATION
const GRAVITY = 200.0
const SPEED = 20.0
const CHARGE_MULTIPLIER = 1.50
const MAX_FALL_SPEED = 60.0
const CHARGE_RANGE = 100.0
const WANDER_CHANGE_INTERVAL = 3.0  # seconds to change patrol direction

const max_hp = 30
@onready var player = $"../../Player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# KNOCKBACK SETTINGS
@export var knockback_force: float = 300.0
@export var knockback_duration: float = 0.2

@export var KNOCKBACK_FORCE: float = 50.0
@export var KNOCKBACK_TIME: float = 0.2
var is_knocked_back := false

# STATE VARIABLES
var hp: int
var wander_direction: int = 0  # -1 left, 0 idle, 1 right
var wander_timer: float = 0.0
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	hp = max_hp
	sprite.play("default")
	_set_new_wander_direction()
	
	var area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func _physics_process(delta: float) -> void:
	if not player:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	else:
		velocity.y = 0

	# --- Knockback handling ---
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		if knockback_timer <= 0:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return


	# --- Normal AI movement ---
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

# --- WANDER LOGIC ---
func _set_new_wander_direction() -> void:
	wander_direction = randi() % 3 - 1  # -1, 0, 1
	wander_timer = WANDER_CHANGE_INTERVAL

# --- DAMAGE + KNOCKBACK ---
func take_damage(amount: int, source_pos: Vector2) -> void:
	hp -= amount
	print("Zombie HP:", hp)

	if hp <= 0:
		die()
		return

	var knock_dir = (global_position - source_pos).normalized()
	knockback_velocity = knock_dir * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_TIME
	is_knocked_back = true

##COMBAT SYSTEM CODE
func get_damage() -> int:
	return 1


func die() -> void:
	print("[Zombie] 💀 Defeated.")
	queue_free()

func _on_body_entered(body: Node) -> void:
	
	print("[Jombie] Hit:", body.name)
	
	if body.name == "Player" or body.is_in_group("player"):
		print("[Jombie] Hit:", body.name)
