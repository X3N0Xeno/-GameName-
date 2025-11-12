extends CharacterBody2D

# === CONFIG ===
@export var SPEED: float = 25.0
@export var VISIBLE_RANGE: float = 100.0
@export var HOVER_HEIGHT: float = 2.0
@export var HOVER_SPEED: float = 2.0
@export var max_hp: int = 20

# === NODE REFERENCES ===
@onready var player = $"../../Player"

@export var knockback_force: float = 300.0
@export var knockback_duration: float = 0.3
@export var KNOCKBACK_FORCE: float = 100.0
@export var KNOCKBACK_TIME: float = 0.2
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knocked_back := false
@onready var sprite = $AnimatedSprite2D
var rng := RandomNumberGenerator.new()
# === STATE VARIABLES ===
var hp: int
var target_visible := false
var hover_timer := 0.0

func _ready() -> void:
	hp = max_hp
	modulate.a = 0.0  # start invisible
	var costume = 0
	costume = rng.randi_range(1, 4)
	match costume:
		1:
			sprite.play("default1")
		2:
			sprite.play("default4")
		3:
			sprite.play("default3")
		4:
			sprite.play("default4")

func _physics_process(delta: float) -> void:
	if not player:
		return

	# Distance check
	var dist: float = global_position.distance_to(player.global_position)
	var should_be_visible: bool = dist <= VISIBLE_RANGE

	if should_be_visible != target_visible:
		target_visible = should_be_visible
		_fade(target_visible)
	#GPT rocks
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
		
	# --- Knockback handling ---
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		if knockback_timer <= 0:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return

	move_and_slide()

# === DAMAGE / KNOCKBACK ===
func take_damage(amount: int, source_pos: Vector2) -> void:
	hp -= amount
	print("Ghost HP:", hp)

	if hp <= 0:
		queue_free()
		return

	var knock_dir = (global_position - source_pos).normalized()
	knockback_velocity = knock_dir * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_TIME
	is_knocked_back = true

##COMBAT SYSTEM CODE
func get_damage() -> int:
	return 1
# === FADE EFFECT ===
func _fade(_show: bool) -> void:
	var tween = get_tree().create_tween()
	if show:
		tween.tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
