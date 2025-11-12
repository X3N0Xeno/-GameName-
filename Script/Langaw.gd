extends CharacterBody2D

# ======================
# === CONFIG ===========
# ======================
@export var ORBIT_RADIUS: float = 20.0
@export var ORBIT_SPEED: float = 1.0
@export var CHASE_RADIUS: float = 50.0
@export var ABOVE_PLAYER_HEIGHT: float = 20.0
@export var SPEED_MULTIPLIER_NEAR_PLAYER: float = 1.5
@export var RETURN_SPEED: float = 3.0
@export var max_hp: int = 24

# ======================
# === KNOCKBACK ========
# ======================
@export var KNOCKBACK_FORCE: float = 100.0
@export var KNOCKBACK_TIME: float = 0.2
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knocked_back := false

# ======================
# === NODE REFS ========
# ======================
@onready var player =  $"../../Player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# ======================
# === STATE ============
# ======================
var hp: int
var angle: float = 0.0
var idle_origin: Vector2

# ======================
# === READY ============
# ======================
func _ready() -> void:
	hp = max_hp
	idle_origin = global_position
	sprite.play("default")
	var area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

# ======================
# === PHYSICS ==========
# ======================
func _physics_process(delta: float) -> void:
	if is_knocked_back:
		# Blend knockback with current velocity
		velocity.x = lerp(velocity.x, knockback_velocity.x, 0.2)
		velocity.y += knockback_velocity.y * delta
		move_and_slide()
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false
			velocity = Vector2.ZERO
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
	velocity = (target_pos - global_position) * 5.0 * speed_mult

	move_and_slide()

# ======================
# === DAMAGE ===========
# ======================
func take_damage(amount: int, source_pos: Vector2) -> void:
	hp -= amount
	print("Langaw HP:", hp)

	if hp <= 0:
		queue_free()
		return

	# --- Horizontal knockback + small vertical lift ---
	var knock_dir = (global_position - source_pos).normalized()
	knockback_velocity = Vector2(knock_dir.x * KNOCKBACK_FORCE, -KNOCKBACK_FORCE * 0.2)
	knockback_timer = KNOCKBACK_TIME
	is_knocked_back = true

	# --- Flash white when hit ---
	if sprite:
		sprite.modulate = Color(2, 2, 2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

# ======================
# === COMBAT SYSTEM ====
# ======================
func get_damage() -> int:
	return 1
