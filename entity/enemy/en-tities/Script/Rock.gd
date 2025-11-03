extends CharacterBody2D

# --- CONFIG ---
@export var SPEED: float = 450.0       # horizontal speed
@export var GRAVITY: float = 200.0     # gravity while falling
@export var ROTATE_SPEED: float = 360.0 # degrees/sec
@export var LIFETIME: float = 4.0      # seconds before disappearing
@export var RETURN_SPEED: float = 500.0 # speed when reflected
@export var DOWN_BIAS: float = 50.0    # downward bias added to initial launch

# --- STATE ---
var lifetime_timer: float = 0.0
var rng := RandomNumberGenerator.new()
var returning: bool = false

func _ready() -> void:
	rng.randomize()
	lifetime_timer = LIFETIME

	# Normal launch: random angle up with slight downward bias
	var angle = rng.randf_range(-PI/4, PI/4)
	velocity.x = SPEED * cos(angle)
	velocity.y = SPEED * -sin(angle) + DOWN_BIAS  # downward bias added

	# Connect Area2D collision
	$Area2D.connect("body_entered", _on_area_entered)

func _physics_process(delta: float) -> void:
	# Apply gravity if not returning
	if not returning:
		velocity.y += GRAVITY * delta
	
	move_and_slide()
	rotation_degrees += ROTATE_SPEED * delta

	# Lifetime countdown
	lifetime_timer -= delta
	if lifetime_timer <= 0.0:
		queue_free()

# --- Reflect rock toward left (boss side) ---
func reflect_to() -> void:
	if returning:
		return
	returning = true
	velocity = Vector2(-RETURN_SPEED, 0)  # fixed leftward velocity

# --- Collision handler ---
func _on_area_entered(body: Node) -> void:
	if returning:
		# Hit the boss
		if body.has_method("take_damage"):
			body.take_damage(50, global_position)
		queue_free()
	else:
		# Hit player
		if body.name == "HK":
			# body.take_damage(1, global_position)
			queue_free()

# --- Debug: launch back when pressing test_damage ---
func _input(event):
	if event.is_action_pressed("test_damage") and not returning:
		reflect_to()
