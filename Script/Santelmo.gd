extends CharacterBody2D

# === SANTELMO CONFIG ===
@export var hover_height: float = 10.0
@export var hover_speed: float = 1.5
@export var move_speed: float = 120.0

@export var aggro_range: float = 600.0
@export var explode_range: float = 150.0
@export var explode_delay: float = 0.6
@export var explode_linger: float = 1.2
@export var explode_damage: int = 2
@export var death_explode_damage_mult: float = 2
@export var max_hp: int = 20

@export var EXPLOSION_DURATION: float = 0.5

# === NODE REFS ===
@onready var player = get_node_or_null("../../HK")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_area: Area2D = $Explosion
@onready var col_attack: CollisionShape2D = $Explosion/Attack
@onready var col_death: CollisionShape2D = $Explosion/Death

# === STATE VARS ===
var hp: int
var hover_timer: float = 0.0
var is_dead: bool = false

# === READY ===
func _ready() -> void:
	hp = max_hp
	close_explosion()
	if explosion_area:
		explosion_area.connect("body_entered", Callable(self, "_on_explosion_hit"))
	print("[Santelmo] Ready — hovering menace online. HP:", hp)

# === PHYSICS PROCESS ===
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not player:
		_hover_motion(delta)
		move_and_slide()
		return

	var dist = global_position.distance_to(player.global_position)

	if dist <= explode_range:
		# 💥 Instantly trigger death explosion
		hp = 0
		await die()
	elif dist <= aggro_range:
		_chase_player(delta)
	else:
		_hover_motion(delta)

	move_and_slide()

# === MOVEMENT ===
func _hover_motion(delta: float):
	hover_timer += delta * hover_speed
	var offset_y = sin(hover_timer) * hover_height
	velocity = Vector2(0, offset_y * 0.5)

func _chase_player(delta: float):
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	sprite.flip_h = velocity.x > 0

# === DEATH EXPLOSION ===
func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO

	print("[Santelmo] ☠️ Death explosion triggered!")

	open_death_explosion()
	var tween = _play_explosion_visuals("death")
	if tween:
		await tween.finished

	await get_tree().create_timer(explode_linger).timeout
	queue_free()

# === EXPLOSION AREA CONTROL ===
func open_death_explosion():
	col_attack.disabled = true
	col_death.disabled = false
	explosion_area.monitoring = true
	explosion_area.monitorable = true

func close_explosion():
	col_attack.disabled = true
	col_death.disabled = true
	explosion_area.monitoring = false
	explosion_area.monitorable = false

# === VISUALS ===
func _play_explosion_visuals(kind: String) -> Tween:
	if not sprite:
		return null

	sprite.scale = Vector2(1.0, 1.0)
	sprite.modulate = Color(1, 1, 1, 1)

	var tint = Color(1.6, 0.4, 0.2, 1.0)
	sprite.modulate = tint

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(2.8, 2.8), EXPLOSION_DURATION * 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, EXPLOSION_DURATION * 0.4).set_delay(EXPLOSION_DURATION * 0.6)
	return tween

# === SIGNAL CALLBACK ===
func _on_explosion_hit(body: Node) -> void:
	if not body:
		return
	print("[Santelmo] 💥 Explosion hit:", body.name)
	if body.has_method("take_damage"):
		body.take_damage(explode_damage)

# === DAMAGE HANDLING ===
func take_damage(amount: int, from: Vector2) -> void:
	if is_dead:
		return

	hp -= amount
	print("[Santelmo] 💥 Took", amount, "damage! HP =", hp)

	var knock_dir = (global_position - from).normalized()
	var knock_strength = 250.0
	velocity = knock_dir * knock_strength
	move_and_slide()

	if sprite:
		sprite.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

	if hp <= 0:
		await get_tree().create_timer(0.1).timeout
		die()

func get_damage():
	return 1
