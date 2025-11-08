extends CharacterBody2D

# ======================
# === CONFIGURATION ===
# ======================
@export var SPEED: float = 50.0
@export var VISIBLE_RANGE: float = 400.0
@export var HOVER_HEIGHT: float = 8.0
@export var HOVER_SPEED: float = 2.0
@export var KNOCKBACK_FORCE: float = 400.0
@export var KNOCKBACK_TIME: float = 0.2
@export var max_hp: int = 3

# ======================
# === NODE REFERENCES ===
# ======================
@onready var player = $"../../HK"

# ======================
# === STATE VARIABLES ===
# ======================
var hp: int
var target_visible := false
var is_knocked_back := false
var hover_timer := 0.0

func _ready() -> void:
	hp = max_hp
	modulate.a = 0.0  # start invisible

func _physics_process(delta: float) -> void:
	if not player:
		return

	# Distance check
	var dist: float = global_position.distance_to(player.global_position)
	var should_be_visible: bool = dist <= VISIBLE_RANGE

	if should_be_visible != target_visible:
		target_visible = should_be_visible
		_fade(target_visible)

	# Ghost movement if visible and not knocked back
	if target_visible and not is_knocked_back:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		# Smooth horizontal and vertical movement toward player
		velocity.x = lerp(float(velocity.x), float(direction.x * SPEED), 0.1)
		velocity.y = lerp(float(velocity.y), float(direction.y * SPEED), 0.1)

		# Add small hover offset on top of vertical movement
		hover_timer += delta * HOVER_SPEED
		velocity.y += sin(hover_timer) * HOVER_HEIGHT
	else:
		# Slow down if knocked back or invisible
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * delta)

	move_and_slide()

# ======================
# === DAMAGE / KNOCKBACK ===
# ======================
func take_damage(amount: int, from: Vector2) -> void:
	hp -= amount
	print("Ghost HP:", hp)

	if hp <= 0:
		queue_free()
		return

	var knock_dir: Vector2 = (global_position - from).normalized()
	velocity = knock_dir * KNOCKBACK_FORCE
	is_knocked_back = true

	# Timer to end knockback
	var knock_timer := get_tree().create_timer(KNOCKBACK_TIME)
	knock_timer.timeout.connect(func(): is_knocked_back = false)

# ======================
# === FADE EFFECT ===
# ======================
func _fade(show: bool) -> void:
	var tween = get_tree().create_tween()
	if show:
		tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ======================
# === DEBUG DAMAGE INPUT ===
# ======================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test_damage") and player:
		take_damage(1, player.global_position)
