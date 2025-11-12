extends CharacterBody2D

# === CONFIGURATION ===
@export var GRAVITY: float = 300.0
@export var JUMP_FORCE: float = 200.0
@export var HOP_DISTANCE: float = 80.0      # fixed horizontal distance per jump
@export var HOP_INTERVAL: float = 2.0        # seconds between jumps
@export var VISIBLE_RANGE: float = 150.0
@export var FADE_TIME: float = 0.5

# === KNOCKBACK SETTINGS ===
@export var KNOCKBACK_FORCE: float = 0.0
@export var KNOCKBACK_TIME: float = 0.4
var knockback_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knocked_back := false

# === HEALTH ===
@export var max_hp: int = 50
var hp: int = 50
var is_dead: bool = false

# === STATE ===
var is_visible := false
var hop_timer := 0.0
var direction := 1 # 1 = right, -1 = left

# === NODE REFERENCES ===
@onready var player = $"../../../Player"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area = $Area2D

# === READY ===
func _ready() -> void:
	sprite.play("default")
	modulate.a = 0.0
	hop_timer = HOP_INTERVAL

	if area:
		area.connect("body_entered", Callable(self, "_on_body_entered"))

# === PHYSICS ===
func _physics_process(delta: float) -> void:
	if not player or is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Knockback handling
	if is_knocked_back:
		knockback_timer -= delta
		velocity.x = lerp(velocity.x, knockback_velocity.x, 0.2)
		velocity.y += knockback_velocity.y * delta
		move_and_slide()
		if knockback_timer <= 0:
			is_knocked_back = false
		return

	# Check visibility distance
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

# === JUMP LOGIC ===
func _jump() -> void:
	direction *= -1 # alternate jump direction

	# calculate horizontal speed to reach HOP_DISTANCE
	var time_in_air = (2 * JUMP_FORCE) / GRAVITY
	var horizontal_speed = (HOP_DISTANCE / time_in_air)

	velocity.x = direction * horizontal_speed
	velocity.y = -JUMP_FORCE

	sprite.flip_h = direction > 0

# === FADE EFFECT ===
func _fade(show: bool) -> void:
	var tween = get_tree().create_tween()
	if show:
		tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	else:
		tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)

# === DAMAGE HANDLING ===
func take_damage(amount: int, source_pos: Vector2) -> void:
	if is_dead:
		return

	hp -= amount
	print("Ghost HP:", hp)

	if hp <= 0:
		die()
		return

	var knock_dir = (global_position - source_pos).normalized()
	knockback_velocity = knock_dir * KNOCKBACK_FORCE
	knockback_timer = KNOCKBACK_TIME
	is_knocked_back = true

	# flash white when hit
	if sprite:
		sprite.modulate = Color(2, 2, 2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

# === DEATH HANDLER ===
func die() -> void:
	if is_dead:
		return
	is_dead = true
	print("[Spirit] ☠️ Vanished into mist...")

	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	await tween.finished
	queue_free()

# === COMBAT SYSTEM ===
func get_damage() -> int:
	return 1

# === COLLISION HANDLER ===
func _on_body_entered(body: Node) -> void:
	if not body:
		return
	if body.is_in_group("player") or body.name == "HK":
		print("[Sigbin] Hit:", body.name)
		if body.has_method("take_damage"):
			body.take_damage(get_damage(), global_position)
