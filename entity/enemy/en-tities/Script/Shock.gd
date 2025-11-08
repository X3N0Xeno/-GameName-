extends CharacterBody2D

# ======================
# === CONFIG ===========
# ======================
@export var SPEED: float = 300.0   # pixels per second
@export var LIFETIME: float = 3.0  # seconds before disappearing

# ======================
# === STATE ============
# ======================
var timer: float = 0.0

func _ready() -> void:
	timer = LIFETIME

func _physics_process(delta: float) -> void:
	# Move right
	velocity = Vector2(SPEED, 0)
	move_and_slide()

	# Countdown lifetime
	timer -= delta
	if timer <= 0.0:
		queue_free()
