extends CharacterBody2D

# ======================
# === CONFIG ===========
# ======================
@export var HOVER_SPEED: float = 4.0
@export var HOVER_HEIGHT: float = 12.0
@export var MOVE_SPEED: float = 120.0
@export var DART_SPEED: float = 330.0
@export var DART_DISTANCE: float = 150.0
@export var DETECT_RANGE: float = 800.0
@export var RETREAT_TIME: float = 0.4
@export var RETURN_SPEED: float = 150.0
@export var max_hp: int = 5

# Knockback (faster version)
@export var KNOCKBACK_FORCE: float = 450.0
@export var KNOCKBACK_TIME: float = 0.15

# Dart cooldown
@export var DART_COOLDOWN: float = 0.3

# ======================
# === NODE REFS ========
# ======================
@onready var player = $"../../HK"
@onready var hitbox = $Area2D/CollisionShape2D

# ======================
# === STATE ============
# ======================
var hp: int
var hover_timer: float = 0.0
var darting: bool = false
var retreating: bool = false
var returning: bool = false
var is_knocked_back: bool = false
var idle_origin: Vector2
var can_dart: bool = true

# ======================
# === READY ============
# ======================
func _ready() -> void:
	hp = max_hp
	hitbox.disabled = false
	idle_origin = global_position

# ======================
# === MAIN LOOP ========
# ======================
func _physics_process(delta: float) -> void:
	if not player or is_knocked_back:
		move_and_slide()
		return

	hover_timer += delta * HOVER_SPEED
	var hover_offset = sin(hover_timer) * HOVER_HEIGHT

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player.normalized()

	if darting or retreating or returning:
		move_and_slide()
		return

	# --- HOVER / TRACKING ---
	if dist < DETECT_RANGE and dist > 40.0:
		velocity = dir * MOVE_SPEED
	elif dist <= 40.0:
		velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	# Add hover movement
	velocity.y += hover_offset * delta * 5.0

	# --- DART TRIGGER ---
	if dist < DART_DISTANCE and can_dart:
		_start_dart(dir)

	move_and_slide()

# ======================
# === DART LOGIC =======
# ======================
func _start_dart(dir: Vector2) -> void:
	if not can_dart:
		return
	can_dart = false
	darting = true
	velocity = dir * DART_SPEED

	var timer = get_tree().create_timer(RETREAT_TIME)
	timer.timeout.connect(_start_retreat)

	# Cooldown
	var cooldown = get_tree().create_timer(DART_COOLDOWN + RETREAT_TIME * 2)
	cooldown.timeout.connect(func(): can_dart = true)

func _start_retreat() -> void:
	retreating = true
	darting = false
	velocity = -velocity * 0.4

	var timer = get_tree().create_timer(RETREAT_TIME)
	timer.timeout.connect(_start_return)

func _start_return() -> void:
	retreating = false
	returning = true

# ======================
# === RETURN HOME ======
# ======================
func _process(delta: float) -> void:
	if returning and not is_knocked_back:
		var to_origin = idle_origin - global_position
		if to_origin.length() < 5.0:
			returning = false
			velocity = Vector2.ZERO
			global_position = global_position.lerp(idle_origin, 0.5)
		else:
			velocity = to_origin.normalized() * RETURN_SPEED
			move_and_slide()

# ======================
# === DAMAGE / KNOCKBACK ===
# ======================
func take_damage(amount: int, from: Vector2) -> void:
	if is_knocked_back:
		return

	hp -= amount
	print("Mosquito HP:", hp)

	if hp <= 0:
		queue_free()
		return

	# Knockback direction and effect
	is_knocked_back = true
	var knock_dir = (global_position - from).normalized()
	velocity = knock_dir * KNOCKBACK_FORCE

	# Timer to end knockback
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
