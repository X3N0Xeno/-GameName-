extends CharacterBody2D

# ======================
# === CONFIGURATION ===
# ======================
@export var GRAVITY: float = 600.0
@export var JUMP_FORCE: float = 450.0
@export var HOP_DISTANCE: float = 200.0   # fixed horizontal distance per jump
@export var HOP_INTERVAL: float = 1.0     # seconds between jumps
@export var VISIBLE_RANGE: float = 350.0
@export var FADE_TIME: float = 0.5

@onready var player = $"../../HK"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area = $Area2D
@onready var colshape = $Area2D/CollisionShape2D

# ======================
# === STATE VARS ===
# ======================
var is_visible := false
var hop_timer := 0.0
var direction := 1 # 1 = right, -1 = left

func _ready() -> void:
	modulate.a = 0.0
	hop_timer = HOP_INTERVAL

func _physics_process(delta: float) -> void:
	if not player:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Distance check for visibility
	var dist = global_position.distance_to(player.global_position)
	var should_be_visible = dist <= VISIBLE_RANGE

	if should_be_visible != is_visible:
		is_visible = should_be_visible
		_fade(is_visible)

	# Hopping behavior
	if is_visible:
		hop_timer -= delta
		if hop_timer <= 0.0 and is_on_floor():
			_jump()
			hop_timer = HOP_INTERVAL

	move_and_slide()

# ======================
# === JUMP LOGIC ===
# ======================
func _jump() -> void:
	# Alternate jump direction
	direction *= -1

	# Fixed-distance jump (convert to velocity)
	var time_in_air = (2 * JUMP_FORCE) / GRAVITY
	var horizontal_speed = HOP_DISTANCE / time_in_air

	velocity.x = direction * horizontal_speed
	velocity.y = -JUMP_FORCE

	# Reverse flip (faces the *wrong* way on purpose)
	sprite.flip_h = direction > 0  # normally you'd do < 0, but this is backwards for the gag

# ======================
# === FADE EFFECT ===
# ======================
func _fade(show: bool) -> void:
	var tween = get_tree().create_tween()
	if show:
		tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	else:
		tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
