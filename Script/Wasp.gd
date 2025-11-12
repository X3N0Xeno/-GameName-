extends CharacterBody2D

# === CONFIG ===========
@export var HOVER_SPEED: float = 5.0
@export var HOVER_HEIGHT: float = 18.0
@export var MOVE_SPEED: float = 40.0
@export var DART_SPEED: float = 100.0
@export var DART_DISTANCE: float = 50.0
@export var DETECT_RANGE: float = 200.0
@export var RETREAT_TIME: float = 0.35
@export var RETURN_SPEED: float = 40.0
@export var max_hp: int = 40

# Knockback
@export var KNOCKBACK_FORCE: float = 100.0
@export var KNOCKBACK_TIME: float = 0.2
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knocked_back := false

# Dart cooldown
@export var DART_COOLDOWN: float = 0.25

# === NODE REFS ========
@onready var player = $"../../Player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# === STATE ===========
var hp: int
var hover_timer: float = 0.0
var darting: bool = false
var retreating: bool = false
var returning: bool = false
var idle_origin: Vector2
var can_dart: bool = true

# === READY ===========
func _ready() -> void:
	hp = max_hp
	sprite.play("default")
	idle_origin = global_position

	var area = $Area2D
	if area:
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

# === MAIN LOOP =======
func _physics_process(delta: float) -> void:
	if not player:
		return

	hover_timer += delta * HOVER_SPEED
	var hover_offset = sin(hover_timer) * HOVER_HEIGHT

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player.normalized()

	# --- Knockback handling ---
	if knockback_timer > 0:
		knockback_timer -= delta
		# Blend knockback with AI movement
		velocity.x = lerp(velocity.x, knockback_velocity.x, 0.2)
		velocity.y += knockback_velocity.y * delta
		move_and_slide()
		if knockback_timer <= 0:
			is_knocked_back = false
		return

	# --- Movement AI ---
	if darting or retreating or returning:
		move_and_slide()
		return

	if dist < DETECT_RANGE and dist > 60.0:
		velocity = dir * MOVE_SPEED
	elif dist <= 60.0:
		velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	# Hover bob
	velocity.y += hover_offset * delta * 8.0

	# Dart trigger
	if dist < DART_DISTANCE and can_dart:
		_start_dart(dir)

	move_and_slide()

# === DART LOGIC ======
func _start_dart(dir: Vector2) -> void:
	if not can_dart:
		return
	can_dart = false
	darting = true
	velocity = dir * DART_SPEED

	# Retreat after hit window
	var retreat_timer = get_tree().create_timer(RETREAT_TIME)
	retreat_timer.timeout.connect(_start_retreat)

	# Short cooldown for next dart
	var cooldown = get_tree().create_timer(DART_COOLDOWN + RETREAT_TIME * 1.5)
	cooldown.timeout.connect(func(): can_dart = true)

func _start_retreat() -> void:
	retreating = true
	darting = false
	velocity = -velocity * 0.5

	var timer = get_tree().create_timer(RETREAT_TIME)
	timer.timeout.connect(_start_return)

func _start_return() -> void:
	retreating = false
	returning = true

# === RETURN HOME =====
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

# === DAMAGE + KNOCKBACK ===
func take_damage(amount: int, source_pos: Vector2) -> void:
	hp -= amount
	print("Wasp HP:", hp)

	if hp <= 0:
		queue_free()
		return

	# --- Knockback: horizontal only + small lift ---
	var knock_dir = (global_position - source_pos).normalized()
	knockback_velocity = Vector2(knock_dir.x * KNOCKBACK_FORCE, -KNOCKBACK_FORCE * 0.2)
	knockback_timer = KNOCKBACK_TIME
	is_knocked_back = true

	# --- Flash white when hit ---
	if sprite:
		sprite.modulate = Color(2, 2, 2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

# === COMBAT SYSTEM ===
func get_damage() -> int:
	return 1
