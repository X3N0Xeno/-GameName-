extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -700.0

@export var fall_multiplier: float = 2.0        # fall faster
@export var low_jump_multiplier: float = 3.0    # small hop if jump released early
@export var attack_range: float = 200.0         # distance to player to trigger attack

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = $"../../HK"  # adjust path to player

func _physics_process(delta: float) -> void:
	# --- gravity with fall multipliers ---
	if not is_on_floor():
		if velocity.y > 0: # falling
			velocity += get_gravity() * fall_multiplier * delta
		elif velocity.y < 0 and not Input.is_action_pressed("ui_accept"):
			# going up, but jump released → stronger gravity
			velocity += get_gravity() * low_jump_multiplier * delta
		else:
			# normal gravity
			velocity += get_gravity() * delta

	# --- handle jump ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- horizontal movement ---
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		# --- flip sprite ---
		if sprite:
			sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- check attack range ---
	if player and global_position.distance_to(player.global_position) <= attack_range:
		print("[DEBUG] Player is in attack range!")

	# --- apply motion ---
	move_and_slide()
