extends CharacterBody2D

# =====================
# === MOVEMENT CONFIG ==
# =====================
const SPEED = 300.0
const JUMP_VELOCITY = -700.0

@export var fall_multiplier: float = 2.0
@export var low_jump_multiplier: float = 3.0
@export var attack_range: float = 200.0

# =====================
# === ATTACK CONFIG ===
# =====================
@export var attack_duration: float = 0.5    # How long sword stays active
@export var attack_cooldown: float = 0.6    # Cooldown between swings
@export var damage: int = 10                # Damage dealt per hit
@export var knockback_force: float = 400.0  # Optional knockback push

# =====================
# === NODE REFS =======
# =====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_area: Area2D = $Area2D
@onready var sword_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var player = $"../../HK"  # Keep if needed, else can remove

# =====================
# === STATE ===========
# =====================
var can_attack: bool = true
var is_attacking: bool = false

# =====================
# === PHYSICS =========
# =====================
func _physics_process(delta: float) -> void:
	# --- Gravity with fall multipliers ---
	if not is_on_floor():
		if velocity.y > 0:
			velocity += get_gravity() * fall_multiplier * delta
		elif velocity.y < 0 and not Input.is_action_pressed("ui_accept"):
			velocity += get_gravity() * low_jump_multiplier * delta
		else:
			velocity += get_gravity() * delta

	# --- Jump ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Movement ---
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if sprite:
			sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- Attack ---
	if Input.is_action_just_pressed("attack") and can_attack:
		start_attack()

	move_and_slide()

# =====================
# === ATTACK LOGIC ====
# =====================
func start_attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	can_attack = false

	# Enable hitbox
	sword_shape.disabled = false
	print("[PLAYER] Sword active!")

	# Connect signal temporarily
	sword_area.connect("body_entered", _on_sword_hit, CONNECT_ONE_SHOT)

	# Disable hitbox after duration
	await get_tree().create_timer(attack_duration).timeout
	sword_shape.disabled = true
	print("[PLAYER] Sword inactive!")

	is_attacking = false

	# Cooldown before next attack
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

# =====================
# === HIT DETECTION ===
# =====================
func _on_sword_hit(body: Node) -> void:
	if not body:
		return
		
	
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
		print("[PLAYER] Hit:", body.name, "for", damage, "damage!")

	# --- Optional knockback (for simpler enemies) ---
	elif body.has_method("knockback"):
		var dir = sign(body.global_position.x - global_position.x)
		body.knockback(Vector2(dir * knockback_force, -100))
		print("[PLAYER] Knockback applied to:", body.name)
