extends CharacterBody2D

# ======================
# === CONFIG ===========
# ======================
@export var ORBIT_RADIUS: float = 100.0
@export var ORBIT_SPEED: float = 2.0
@export var CHASE_RADIUS: float = 300.0
@export var ABOVE_PLAYER_HEIGHT: float = 60.0
@export var SPEED_MULTIPLIER_NEAR_PLAYER: float = 1.5
@export var RETURN_SPEED: float = 3.0
@export var max_hp: int = 2

# Knockback settings
@export var KNOCKBACK_FORCE: float = 400.0
@export var KNOCKBACK_TIME: float = 0.15

# ======================
# === NODE REFS ========
# ======================
@onready var player = $"../../HK"
@onready var hitbox = $Area2D/CollisionShape2D

# ======================
# === STATE ============
# ======================
var hp: int
var angle: float = 0.0
var is_knocked_back: bool = false
var idle_origin: Vector2

# ======================
# === READY ============
# ======================
func _ready() -> void:
	hp = max_hp
	hitbox.disabled = false
	idle_origin = global_position

# ======================
# === PHYSICS ==========
# ======================
func _physics_process(delta: float) -> void:
	if is_knocked_back:
		move_and_slide()
		return

	angle += ORBIT_SPEED * delta

	var orbit_center: Vector2 = idle_origin
	var speed_mult = 1.0

	# --- Player proximity logic ---
	if player:
		var dist_to_player = global_position.distance_to(player.global_position)

		if dist_to_player < CHASE_RADIUS:
			speed_mult = SPEED_MULTIPLIER_NEAR_PLAYER
			orbit_center = player.global_position + Vector2(0, -ABOVE_PLAYER_HEIGHT)
		else:
			# Slowly drift back to idle spot
			idle_origin = idle_origin.lerp(global_position, delta * RETURN_SPEED)

	# Orbiting motion
	var offset = Vector2(cos(angle), sin(angle)) * ORBIT_RADIUS
	var target_pos = orbit_center + offset
	velocity = (target_pos - global_position) * 5.0
	move_and_slide()

# ======================
# === DAMAGE / KNOCKBACK ===
# ======================
func take_damage(amount: int, from: Vector2) -> void:
	if is_knocked_back:
		return

	hp -= amount
	print("Fly HP:", hp)

	if hp <= 0:
		queue_free()
		return

	# Apply knockback
	is_knocked_back = true
	var knock_dir = (global_position - from).normalized()
	velocity = knock_dir * KNOCKBACK_FORCE

	var knock_timer := get_tree().create_timer(KNOCKBACK_TIME)
	knock_timer.timeout.connect(func():
		is_knocked_back = false
		velocity = Vector2.ZERO
	)

# ======================
# === DEBUG ============
# ======================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_damage") and player:
		take_damage(1, player.global_position)
