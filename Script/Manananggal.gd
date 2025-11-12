extends CharacterBody2D

# ======================
# === CONFIG ===========
# ======================
@export var HOVER_SPEED: float = 4.0
@export var HOVER_HEIGHT: float = 8.0
@export var HOVER_RADIUS: float = 60.0  # how far it hovers around the player
@export var MOVE_SPEED: float = 100.0
@export var DART_SPEED: float = 200.0
@export var DART_DISTANCE: float = 100.0
@export var DETECT_RANGE: float = 500.0
@export var RETREAT_TIME: float = 0.4
@export var DART_COOLDOWN: float = 1.5
@export var max_hp: int = 100

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
@onready var player = $"../../Player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# ======================
# === STATE ============
# ======================
var hp: int
var hover_angle: float = 0.0
var darting: bool = false
var retreating: bool = false
var can_dart: bool = true

# ======================
# === READY ============
# ======================
func _ready() -> void:
	hp = max_hp
	sprite.play("Idle")

# ======================
# === PHYSICS ==========
# ======================
func _physics_process(delta: float) -> void:
	if not player:
		return

	# --- Knockback handling ---
	if is_knocked_back:
		velocity = knockback_velocity
		move_and_slide()
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return

	if darting or retreating:
		move_and_slide()
		return

	# --- Hover near player ---
	hover_angle += delta * HOVER_SPEED
	var hover_offset = Vector2(cos(hover_angle), sin(hover_angle)) * HOVER_RADIUS
	var target_pos = player.global_position + hover_offset

	var to_target = target_pos - global_position
	velocity = to_target.normalized() * MOVE_SPEED

	# Add gentle up-down bobbing
	velocity.y += sin(hover_angle * 2.0) * HOVER_HEIGHT * delta * 5.0

	move_and_slide()

	# --- Dart occasionally ---
	if can_dart and player and global_position.distance_to(player.global_position) < DART_DISTANCE:
		_start_dart((player.global_position - global_position).normalized())

# ======================
# === DART LOGIC =======
# ======================
func _start_dart(dir: Vector2) -> void:
	if not can_dart:
		return
	can_dart = false
	darting = true
	sprite.play("Dash")

	velocity = dir * DART_SPEED

	var timer = get_tree().create_timer(RETREAT_TIME)
	timer.timeout.connect(_start_retreat)

	var cooldown = get_tree().create_timer(DART_COOLDOWN)
	cooldown.timeout.connect(func(): can_dart = true)

func _start_retreat() -> void:
	retreating = true
	darting = false
	velocity = -velocity * 0.5

	var timer = get_tree().create_timer(RETREAT_TIME)
	timer.timeout.connect(func():
		retreating = false
		sprite.play("Idle")
	)

# ======================
# === DAMAGE ===========
# ======================
func take_damage(amount: int, source_pos: Vector2) -> void:
	hp -= amount
	print("Manang HP:", hp)

	if hp <= 0:
		PortalManager.is_manananggal_dead =true
		queue_free()
		return

	var knock_dir = (global_position - source_pos).normalized()
	knockback_velocity = knock_dir * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_TIME
	is_knocked_back = true

	if sprite:
		sprite.modulate = Color(2, 2, 2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

# ======================
# === COMBAT SYSTEM ====
# ======================
func get_damage() -> int:
	return 1
